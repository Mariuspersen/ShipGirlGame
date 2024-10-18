const std = @import("std");
const builtin = @import("builtin");
const Common = @import("common.zig");

pub var Allocator: std.mem.Allocator = undefined;
pub var allocMap: ?std.AutoHashMap(usize, usize) = null;

//Change allocator used based on Debug or Release builds
var allocatorType: blk: {
    switch (builtin.mode) {
        .Debug => break :blk std.heap.GeneralPurposeAllocator(.{}),
        else => break :blk std.heap.ArenaAllocator,
    }
} = blk: {
    switch (builtin.mode) {
        .Debug => break :blk std.heap.GeneralPurposeAllocator(.{}){},
        else => break :blk std.heap.ArenaAllocator.init(std.heap.page_allocator),
    }
};

pub fn initAllocator() void {
    Allocator = allocatorType.allocator();
    allocMap = std.AutoHashMap(usize, usize).init(Allocator);
}

pub fn deinitAllocator() void {
    switch (builtin.mode) {
        .Debug => _ = {
            _ = allocatorType.detectLeaks();
            _ = allocatorType.deinit();
        },
        else => {
            allocatorType.deinit();
        },
    }
}

export fn rlMalloc(size: c_int) callconv(.C) ?*anyopaque {
    if (allocMap) |*map| {
        const pointer = Allocator.alloc(u8, @intCast(size)) catch return null;
        map.put(@intFromPtr(pointer.ptr), @intCast(size)) catch {
            Allocator.free(pointer);
            return null;
        };
        return @ptrCast(pointer.ptr);
    }
    else return null;
}

export fn rlCalloc(n: c_int, size: c_int) callconv(.C) ?*anyopaque {
    if (allocMap) |*map| {
        const pointer = Allocator.alloc(u8, @intCast(size*n)) catch return null;
        for (pointer) |*c| {
            c.* = 0;
        }
        map.put(@intFromPtr(pointer.ptr), @intCast(size)) catch {
            Allocator.free(pointer);
            return null;
        };
        return @ptrCast(pointer.ptr);
    }
    else return null;
}

export fn rlFree(ptr: ?*anyopaque) callconv(.C) void {
    if (ptr) |p|
    if (allocMap) |*map|
    if (map.fetchRemove(@intFromPtr(p))) |key| {
        const mem: []u8 = @as([*]u8, @ptrCast(p))[0..key.value];
        Allocator.free(mem);
    };
}

export fn rlRealloc(ptr: ?*anyopaque, size: c_int) callconv(.C) ?*anyopaque {
    if (ptr) |p|
    if (allocMap) |*map|
    if (map.fetchRemove(@intFromPtr(p))) |key| {
        const mem: []u8 = @as([*]u8, @ptrCast(p))[0..key.value];
        const new = Allocator.realloc(mem, @intCast(size)) catch return null;
        map.put(@intFromPtr(new.ptr), @intCast(size)) catch {
            Allocator.free(new);
            return null;
        };
        return @ptrCast(new.ptr);
    };
    return null;
}
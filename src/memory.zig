//Imports
const std = @import("std");
const builtin = @import("builtin");
const Common = @import("common.zig");
const rl = @import("raylib");

//Public Variables
pub var Allocator: std.mem.Allocator = undefined;
//Private Constants
const memAlign = 16;
//Private Variables
var allocationMap: std.AutoHashMap(usize, usize) = undefined;

//Game uses a different type of allocator
//depending on build type
//Release = Arena, Debug = GeneralPurposeAllocator
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
    allocationMap = std.AutoHashMap(usize, usize).init(Allocator);
}

pub fn deinitAllocator() void {
    allocationMap.deinit();
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

export fn rlMalloc(size: usize) callconv(.C) ?*anyopaque {
    const pointer = Allocator.alloc(
        u8,
        size,
    ) catch @panic("Allocator: unable to allocate");

    allocationMap.put(
        @intFromPtr(pointer.ptr),
        size,
    ) catch @panic("allocationMap: unable to add KV pair");

    return pointer.ptr;
}

export fn rlCalloc(n: usize, size: usize) callconv(.C) ?*anyopaque {
    const pointer = Allocator.alloc(
        u8,
        size * n,
    ) catch @panic("Allocator: unable to allocate");

    @memset(pointer, 0);

    allocationMap.put(
        @intFromPtr(pointer.ptr),
        size * n,
    ) catch @panic("allocationMap: unable to add KV pair");

    return pointer.ptr;
}

export fn rlFree(ptr: ?*anyopaque) callconv(.C) void {
    const p = ptr orelse return;
    if (allocationMap.fetchRemove(@intFromPtr(p))) |key| {
        const mem: []u8 = @as([*]u8, @ptrCast(p))[0..key.value];
        Allocator.free(mem);
    }
}

export fn rlRealloc(ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque {
    var p = ptr orelse return rlMalloc(size) orelse return null;

    if (allocationMap.fetchRemove(@intFromPtr(p))) |key| {
        const old: []u8 = @as([*]u8, @ptrCast(p))[0..key.value];
        const new = Allocator.realloc(old, size) catch
            @panic("Allocator: unable to reallocate");

        allocationMap.put(
            @intFromPtr(new.ptr),
            size,
        ) catch @panic("allocationMap: unable to add KV pair");

        p = new.ptr;
    }

    return p;
}

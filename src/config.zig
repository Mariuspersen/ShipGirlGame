const std = @import("std");
const fs = std.fs;

const Common = @import("common.zig");

const Self = @This();

const Defaults = @embedFile("defaults");

const conVar = union(enum) {
    number: i32,
    float: f32,
    string: [:0]const u8,

    pub fn init(data: anytype) conVar {
        return switch (@typeInfo(@TypeOf(data))) {
            .Int => .{ .number = @as(i32,data) },
            .Float => .{ .float = @as(f32,data) },
            .Pointer => .{ .string = data },
            else => @compileError("Not a valid datatype!"),
        };
    }
};

pub var vars: Self = undefined;
var file: std.fs.File = undefined;

hashmap: std.StringHashMap(conVar),

pub fn init(allocator: std.mem.Allocator) !void {
    vars = Self{
        .hashmap = std.StringHashMap(conVar).init(allocator),
    };
    if(fs.cwd().openFile("config", .{ .mode = .read_write })) |f| {
        file = f;
    }
    else |_| {
        file = try std.fs.cwd().createFile("config", .{ .read = true });
        const fWriter = file.writer();
        try fWriter.writeAll(Defaults);
        try file.seekTo(0);
    }
        
    const conFileRead = file.reader();
    try vars.read(conFileRead);
}

pub fn add(self: *Self, name: []const u8, value: anytype) !void {
    const cv: conVar = switch (@typeInfo(@TypeOf(value))) {
        .Int, .Float => conVar.init(value),
        .Pointer => blk: {
            const buf = try self.hashmap.allocator.allocSentinel(u8, value.len,0);
            @memcpy(buf, value);
            break :blk conVar.init(buf);
        },
        else => return error.InvalidConType,
    };

    const buf = try self.hashmap.allocator.alloc(u8, name.len);
    @memcpy(buf, name);

    const res = try self.hashmap.getOrPut(buf);
    if (res.found_existing) {
        const oldVar = self.hashmap.fetchRemove(buf) orelse return error.UnknownConvar;
        switch (oldVar.value) {
            .number, .float => {
                self.hashmap.allocator.free(oldVar.key);
            },
            .string => |s| {
                self.hashmap.allocator.free(s);
                self.hashmap.allocator.free(oldVar.key);
            },
        }
    }
    try self.hashmap.put(buf, cv);
}

pub fn get(self: *Self, T: type, name: []const u8) T {
    if(self.hashmap.get(name)) |cv| {
        return switch (@typeInfo(T)) {
            .Float => cv.float,
            .Int => cv.number,
            .Pointer => cv.string,
            else => @as(T, 0),
        };
    }
    else {
        std.debug.print("Couldn't find {s}\n", .{name});
        return switch (@typeInfo(T)) {
            .Pointer => &.{},
            else => @as(T, 0),
        };
    }
}

pub fn remove(self: *Self, name: []const u8) !void {
    const res = try self.hashmap.getOrPut(name);
    if (res.found_existing) {
        const oldVar = self.hashmap.fetchRemove(name) orelse return error.UnknownConvar;
        switch (oldVar.value) {
            .number, .float => {
                self.hashmap.allocator.free(oldVar.key);
            },
            .string => |s| {
                self.hashmap.allocator.free(s);
                self.hashmap.allocator.free(oldVar.key);
            },
        }
    }
}

pub fn write(self: *Self, writer: anytype) !void {
    var it = self.hashmap.iterator();
    while (it.next()) |e| {
        try writer.writeInt(u8, @as(u8, @intCast(e.key_ptr.*.len)), .little);
        try writer.writeAll(e.key_ptr.*);
        try writer.writeInt(u8, @intFromEnum(e.value_ptr.*), .little);
        switch (e.value_ptr.*) {
            .string => |s| {
                try writer.writeInt(u8, @intCast(s.len), .little);
                try writer.writeAll(s);
            },
            .number => |n| try writer.writeInt(i32, n, .little),
            .float => |f| try writeFloat(writer, f32, f),
        }
    }
}

fn writeFloat(writer: anytype, comptime T: type, value: T) !void {
    const bytes: [@divExact(@typeInfo(T).Float.bits, 8)]u8 = @bitCast(value);
    return writer.writeAll(&bytes);
}

pub fn read(self: *Self, reader: anytype) !void {
    while (true) {
        self.readInternal(reader) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
    }
}

fn readInternal(self: *Self, reader: anytype) !void {
    const name_length = try reader.readInt(u8, .little);
    const name = try self.hashmap.allocator.alloc(u8, name_length);
    _ = try reader.readAtLeast(name, name_length);
    const conVarType = try reader.readInt(u8, .little);
    switch (conVarType) {
        @intFromEnum(conVar.string) => {
            const val_length = try reader.readInt(u8, .little);
            const val = try self.hashmap.allocator.allocSentinel(u8, val_length,0);
            _ = try reader.readAtLeast(val, val_length);
            try self.hashmap.put(name, conVar.init(val));
        },
        @intFromEnum(conVar.number) => {
            const number = try reader.readInt(i32, .little);
            try self.hashmap.put(name, conVar.init(number));
        },
        @intFromEnum(conVar.float) => {
            const float = try readFloat(reader, f32);
            try self.hashmap.put(name, conVar.init(float));
        },
        else => return error.InvalidType,
    }
}

fn readFloat(reader: anytype, comptime T: type) !T {
    const bytes = try reader.readBytesNoEof(@divExact(@typeInfo(T).Float.bits, 8));
    const value: T = @bitCast(bytes);
    return value;
}

pub fn deinit(self: *Self) void {
    const conFileWrite = file.writer();
    file.seekTo(0) catch |err| {
        Common.printError(err);
        return;
    };
    vars.write(conFileWrite) catch |err| {
        Common.printError(err);
        return;
    };


    var it = self.hashmap.iterator();
    it.index = 0;
    while (it.next()) |e| {
        self.hashmap.allocator.free(e.key_ptr.*);
        switch (e.value_ptr.*) {
            .number, .float => {},
            .string => |s| {
                self.hashmap.allocator.free(s);
            },
        }
    }

    const pos = file.getPos() catch |err| {
        Common.printError(err);
        return;
    };
    file.setEndPos(pos) catch |err| {
        Common.printError(err);
        return;
    };
    self.hashmap.deinit();
    file.close();
    vars = undefined;
}

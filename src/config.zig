const std = @import("std");
const Self = @This();
const Defaults = @embedFile("config");

const conType = union(enum) {
    number: i32,
    float: f32,
    string: [:0]const u8,
};

const conVar = struct {
    data: conType,

    pub fn init(data: anytype) !conVar {
        return switch (@typeInfo(@TypeOf(data))) {
            .Int => .{ .data = .{ .number = @intCast(data) } },
            .Float => .{ .data = . { .float = @floatCast(data) }},
            .Pointer => .{ .data = .{ .string = data } },
            else => return error.InvalidConType,
        };
    }
};

pub var vars: Self = undefined;
pub var file: std.fs.File = undefined;

hashmap: std.StringHashMap(conVar),

pub fn init(allocator: std.mem.Allocator) !void {
    vars = Self{
        .hashmap = std.StringHashMap(conVar).init(allocator),
    };
    file = std.fs.cwd().openFile("config", .{ .mode = .read_write }) catch
        try std.fs.cwd().createFile("config", .{ .read = true });
    const conFileRead = file.reader();
    try vars.read(conFileRead);
}

pub fn add(self: *Self, name: []const u8, value: anytype) !void {
    const cv: conVar = try switch (@typeInfo(@TypeOf(value))) {
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
        switch (oldVar.value.data) {
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

const String = [:0]const u8;

pub fn get(self: *Self, T: type, name: []const u8) T {
    if(self.hashmap.get(name)) |cv| {
        return switch (@typeInfo(T)) {
            .Float => cv.data.float,
            .Int => cv.data.number,
            .Pointer => cv.data.string,
            else => @as(T, 0),
        };
    }
    else @panic("YOU GOOFED");
}

pub fn write(self: *Self, writer: anytype) !void {
    var it = self.hashmap.iterator();
    while (it.next()) |e| {
        try writer.writeInt(usize, e.key_ptr.*.len, .little);
        try writer.writeAll(e.key_ptr.*);
        try writer.writeInt(u8, @intFromEnum(e.value_ptr.data), .little);
        switch (e.value_ptr.data) {
            .string => |s| {
                try writer.writeInt(usize, s.len, .little);
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
    const name_length = try reader.readInt(usize, .little);
    const name = try self.hashmap.allocator.alloc(u8, name_length);
    _ = try reader.readAtLeast(name, name_length);
    const contype = try reader.readInt(u8, .little);
    switch (contype) {
        @intFromEnum(conType.string) => {
            const val_length = try reader.readInt(usize, .little);
            const val = try self.hashmap.allocator.allocSentinel(u8, val_length,0);
            _ = try reader.readAtLeast(val, val_length);
            try self.hashmap.put(name, try conVar.init(val));
        },
        @intFromEnum(conType.number) => {
            const number = try reader.readInt(i32, .little);
            try self.hashmap.put(name, try conVar.init(number));
        },
        @intFromEnum(conType.float) => {
            const float = try readFloat(reader, f32);
            try self.hashmap.put(name, try conVar.init(float));
        },
        else => return error.InvalidType,
    }
}

fn readFloat(reader: anytype, comptime T: type) !T {
    const bytes = try reader.readBytesNoEof(@divExact(@typeInfo(T).Float.bits, 8));
    const value: T = @bitCast(bytes);
    return value;
}

pub fn deinit(self: *Self) !void {
    const conFileWrite = file.writer();
    try file.seekTo(0);
    try vars.write(conFileWrite);
    file.close();

    var it = self.hashmap.iterator();
    it.index = 0;
    while (it.next()) |e| {
        self.hashmap.allocator.free(e.key_ptr.*);
        switch (e.value_ptr.*.data) {
            .number, .float => {},
            .string => |s| {
                self.hashmap.allocator.free(s);
            },
        }
    }
    self.hashmap.deinit();
}

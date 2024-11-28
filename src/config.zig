const std = @import("std");
const fs = std.fs;

const Common = @import("common.zig");

const Self = @This();

const Defaults = @embedFile("defaults");

pub const conVar = union(enum) {
    number: i32,
    float: f32,
    string: [:0]const u8,
    flag: u8,

    pub fn init(data: anytype) conVar {
        return switch (@typeInfo(@TypeOf(data))) {
            .Int => .{ .number = @as(i32, data) },
            .Float => .{ .float = @as(f32, data) },
            .Bool => .{ .flag = @intFromBool(data)},
            .Pointer => .{ .string = data },
            else => @compileError("Not a valid datatype!"),
        };
    }

    
};

pub fn typeFromText(text: []const u8) !type {
    const info = @typeInfo(conVar);
    inline for (info.Union.fields) |field| {
        if (std.mem.eql(u8, text, field.name)) {
            return field.type;
        }
    }
    return error.UnknownConvarType;
}

var vars: Self = undefined;
var file: std.fs.File = undefined;

hashmap: std.StringHashMap(conVar),

pub fn init(allocator: std.mem.Allocator) !void {
    vars = Self{
        .hashmap = std.StringHashMap(conVar).init(allocator),
    };
    if (fs.cwd().openFile("config", .{ .mode = .read_write })) |f| {
        file = f;
    } else |_| {
        file = try std.fs.cwd().createFile("config", .{ .read = true });
        const fWriter = file.writer();
        try fWriter.writeAll(Defaults);
        try file.seekTo(0);
    }

    const conFileRead = file.reader();
    try read(conFileRead);
}

pub fn add(name: []const u8, value: anytype) !void {
    const cv: conVar = switch (@typeInfo(@TypeOf(value))) {
        .Int, .Float, .Bool => conVar.init(value),
        .Pointer => blk: {
            const buf = try vars.hashmap.allocator.allocSentinel(u8, value.len, 0);
            @memcpy(buf, value);
            break :blk conVar.init(buf);
        },
        else => return error.InvalidConType,
    };

    const buf = try vars.hashmap.allocator.alloc(u8, name.len);
    @memcpy(buf, name);

    const res = try vars.hashmap.getOrPut(buf);
    if (res.found_existing) {
        const oldVar = vars.hashmap.fetchRemove(buf) orelse return error.UnknownConvar;
        switch (oldVar.value) {
            .number, .float, .flag => {
                vars.hashmap.allocator.free(oldVar.key);
            },
            .string => |s| {
                vars.hashmap.allocator.free(s);
                vars.hashmap.allocator.free(oldVar.key);
            },
        }
    }
    try vars.hashmap.put(buf, cv);
}

pub fn get(T: type, name: []const u8) !T {
    if (vars.hashmap.get(name)) |cv| {
        return switch (@typeInfo(T)) {
            .Float => cv.float,
            .Int => cv.number,
            .Pointer => cv.string,
            .Bool => cv.flag == 1,
            else => error.InvalidConvarType,
        };
    } else return error.ConvarNotInConfig;
}

pub fn remove(name: []const u8) !void {
    const res = try vars.hashmap.getOrPut(name);
    if (res.found_existing) {
        const oldVar = vars.hashmap.fetchRemove(name) orelse return error.UnknownConvar;
        switch (oldVar.value) {
            .number, .float, .flag => {
                vars.hashmap.allocator.free(oldVar.key);
            },
            .string => |s| {
                vars.hashmap.allocator.free(s);
                vars.hashmap.allocator.free(oldVar.key);
            },
        }
    }
}

pub fn write(writer: anytype) !void {
    var it = vars.hashmap.iterator();
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
            .flag => |f| try writer.writeInt(u8, f, .little)
        }
    }
}

fn writeFloat(writer: anytype, comptime T: type, value: T) !void {
    const bytes: [@divExact(@typeInfo(T).Float.bits, 8)]u8 = @bitCast(value);
    return writer.writeAll(&bytes);
}

pub fn read(reader: anytype) !void {
    while (true) {
        readInternal(reader) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
    }
}

fn readInternal(reader: anytype) !void {
    const name_length = try reader.readInt(u8, .little);
    const name = try vars.hashmap.allocator.alloc(u8, name_length);
    _ = try reader.readAtLeast(name, name_length);
    const conVarType = try reader.readInt(u8, .little);
    switch (conVarType) {
        @intFromEnum(conVar.string) => {
            const val_length = try reader.readInt(u8, .little);
            const val = try vars.hashmap.allocator.allocSentinel(u8, val_length, 0);
            _ = try reader.readAtLeast(val, val_length);
            try vars.hashmap.put(name, conVar.init(val));
        },
        @intFromEnum(conVar.number) => {
            const number = try reader.readInt(i32, .little);
            try vars.hashmap.put(name, conVar.init(number));
        },
        @intFromEnum(conVar.float) => {
            const float = try readFloat(reader, f32);
            try vars.hashmap.put(name, conVar.init(float));
        },
        @intFromEnum(conVar.flag) => {
            const flag = try reader.readInt(u8, .little);
            try vars.hashmap.put(name, conVar.init(flag == 1));
        },
        else => return error.InvalidType,
    }
}

fn readFloat(reader: anytype, comptime T: type) !T {
    const bytes = try reader.readBytesNoEof(@divExact(@typeInfo(T).Float.bits, 8));
    const value: T = @bitCast(bytes);
    return value;
}

pub fn deinit() void {
    const conFileWrite = file.writer();
    file.seekTo(0) catch |err| {
        Common.printError(err);
        return;
    };
    write(conFileWrite) catch |err| {
        Common.printError(err);
        return;
    };

    var it = vars.hashmap.iterator();
    it.index = 0;
    while (it.next()) |e| {
        vars.hashmap.allocator.free(e.key_ptr.*);
        switch (e.value_ptr.*) {
            .number, .float, .flag => {},
            .string => |s| {
                vars.hashmap.allocator.free(s);
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
    vars.hashmap.deinit();
    file.close();
    vars = undefined;
}

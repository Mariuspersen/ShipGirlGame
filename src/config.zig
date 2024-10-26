const std = @import("std");
const Self = @This();
const Defaults = @embedFile("config");

const conType = union(enum) {
    number: u64,
    string: []const u8,
};

const conVar = struct {
    data: conType,

    pub fn init(data: anytype) !conVar {
        return switch (@typeInfo(@TypeOf(data))) {
            .Int => .{ .data = .{ .number = @intCast(data) } },
            .Pointer => .{ .data = .{ .string = data } },
            else => return error.invalid_var_type,
        };
    }
};

conVars: std.StringHashMap(conVar),

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .conVars = std.StringHashMap(conVar).init(allocator),
    };
}

pub fn add(self: *Self, name: []const u8, value: anytype) !void {
    const cv = try conVar.init(value);

    const buf = try self.conVars.allocator.alloc(u8, name.len);
    @memcpy(buf, name);

    const res = try self.conVars.getOrPut(buf);
    if (res.found_existing) {
        if (!self.conVars.remove(buf)) return error.UnableToRemoveConvar;
    }
    try self.conVars.put(name, cv);
}

pub fn get(self: *Self, name: []const u8) !conVar {
    return self.conVars.get(name) orelse error.UnknownConVar;
}

pub fn write(self: *Self, writer: anytype) !void {
    var it = self.conVars.iterator();
    while (it.next()) |e| {
        try writer.writeInt(usize, e.key_ptr.*.len, .little);
        try writer.writeAll(e.key_ptr.*);
        try writer.writeInt(u8, @intFromEnum(e.value_ptr.data), .little);
        switch (e.value_ptr.data) {
            .string => |s| {
                try writer.writeInt(u64, s.len, .little);
                try writer.writeAll(s);
            },
            .number => |n| try writer.writeInt(u64, n, .little),
        }
    }
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
    const name = try self.conVars.allocator.alloc(u8, name_length);
    //defer self.conVars.allocator.free(name);
    _ = try reader.readAtLeast(name, name_length);
    const contype = try reader.readInt(u8, .little);
    switch (contype) {
        @intFromEnum(conType.string) => {
            const val_length = try reader.readInt(usize, .little);
            const val = try self.conVars.allocator.alloc(u8, val_length);
            _ = try reader.readAtLeast(val, val_length);
            try self.conVars.put(name, try conVar.init(val));
        },
        @intFromEnum(conType.number) => {
            const number = try reader.readInt(u64, .little);
            try self.conVars.put(name, try conVar.init(number));
        },
        else => return error.InvalidType,
    }
}

pub fn deinit(self: *Self) void {
    var it = self.conVars.iterator();
    while (it.next()) |e| {
        //TODO: Fix memory leak
        //self.conVars.allocator.free(e.key_ptr.*);
        switch (e.value_ptr.*.data) {
            .number => {},
            .string => |s| self.conVars.allocator.free(s),
        }
    }
    self.conVars.deinit();
}

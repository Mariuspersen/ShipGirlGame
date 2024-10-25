const std = @import("std");

pub const conType = union(enum) {
    number: u64,
    string: []const u8,
};

pub const conVar = struct {
    data: conType,

    pub fn init(data: anytype) !conVar {
        return switch (@typeInfo(@TypeOf(data))) {
            .Int => .{ .data = .{ .number = @intCast(data) } },
            .Pointer => .{ .data = .{ .string = data } },
            else => return error.invalid_var_type,
        };
    }
};

pub const Config = struct {
    conVars: std.StringHashMap(conVar),

    pub fn init(allocator: std.mem.Allocator) Config {
        return .{
            .conVars = std.StringHashMap(conVar).init(allocator),
        };
    }

    pub fn add(self: *Config, name: []const u8, value: anytype) !void {
        const cv = try conVar.init(value);
        try self.conVars.put(name, cv);
    }

    pub fn write(self: *Config, writer: anytype) !void {
        var it = self.conVars.iterator();
        while (it.next()) |e| {
            try writer.writeInt(usize, e.key_ptr.*.len, .little);
            try writer.writeAll(e.key_ptr.*);
            try writer.writeInt(usize, @intFromEnum(e.value_ptr.data),.little);
            switch (e.value_ptr.data) {
                .string => |s| try writer.writeAll(s),
                .number => |n| try writer.writeInt(u64,n,.little),
            }
        }
    }

    pub fn deinit(self: *Config) void {
        var it = self.conVars.iterator();
        while(it.next()) |e| {
            switch (e.value_ptr.*.data) {
                .number => {},
                .string => |s| self.conVars.allocator.free(s),
            }
        }
        self.conVars.deinit();
    }
};
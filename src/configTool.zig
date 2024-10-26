const std = @import("std");
const Config = @import("config.zig");
const Memory = @import("memory.zig");

pub fn main() !void {
    Memory.initAllocator();
    defer Memory.deinitAllocator();
    
    try Config.init(Memory.Allocator);
    defer Config.vars.deinit() catch |err| {
        std.debug.print("ERROR: Unable to deinit Config because of {any}!\n", .{err});
    };

    var args = try std.process.argsWithAllocator(Memory.Allocator);
    _ = args.skip();

    const key = args.next() orelse return error.NotEnoughArguments;
    const value = args.next() orelse return error.NotEnoughArguments;
    const valType = args.next() orelse return error.NotEnoughArguments;

    switch (valType[0]) {
        's' => try Config.vars.add(key, value),
        'f' => try Config.vars.add(key, try std.fmt.parseFloat(f32, value)),
        'n' => try Config.vars.add(key, try std.fmt.parseInt(i32, value, 10)),
        else => return error.WrongDataType,
    }
    
}
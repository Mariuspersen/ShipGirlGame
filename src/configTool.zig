const std = @import("std");
const Config = @import("config.zig");
const Memory = @import("memory.zig");

pub fn main() !void {
    Memory.initAllocator();
    defer Memory.deinitAllocator();
    const file = try std.fs.cwd().openFile("config", .{ .mode = .read_write });
    
    var conf = Config.init(Memory.Allocator);
    defer conf.deinit();

    const reader = file.reader();
    try conf.read(reader);

    var args = try std.process.argsWithAllocator(Memory.Allocator);
    _ = args.skip();

    const key = args.next() orelse return error.NotEnoughArguments;
    const value = args.next() orelse return error.NotEnoughArguments;
    const number = std.fmt.parseInt(u64, value, 10);

    if (number) |n| {
        try conf.add(key, n);

    }
    else |_| {
        try conf.add(key, value);
    }

    try file.seekTo(0);
    const writer = file.writer();

    try conf.write(writer);

}
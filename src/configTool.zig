const std = @import("std");
const fs = std.fs;

const Config = @import("config.zig");
const Memory = @import("memory.zig");

pub fn main() !void {
    Memory.initAllocator();
    defer Memory.deinitAllocator();

    if(fs.cwd().openFile("config", .{ .mode = .read_write })) |f| {
        f.close();
    }
    else |_| {
        const file = try fs.cwd().createFile("config", .{ .read = true });
        file.close();
    }

    try Config.init(Memory.Allocator);
    defer Config.deinit();
    
    var args = try std.process.argsWithAllocator(Memory.Allocator);
    defer args.deinit();
    
    _ = args.skip();

    const operation = args.next() orelse return error.NotEnoughArguments;
    const key = args.next() orelse return error.NotEnoughArguments;
    const value = args.next() orelse return error.NotEnoughArguments;
    const valType = args.next() orelse return error.NotEnoughArguments;

    switch (operation[0]) {
        'a' => {
            switch (valType[0]) {
                's' => try Config.add(key, value),
                'f' => try Config.add(key, try std.fmt.parseFloat(f32, value)),
                'n' => try Config.add(key, try std.fmt.parseInt(i32, value, 10)),
                else => return error.WrongDataType,
            }
        },
        'r' => try Config.remove(key),
        else => return error.WrongOperation,
    }
}

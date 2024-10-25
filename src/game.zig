const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const Memory = @import("memory.zig");
const Config = @import("config.zig");
const sceneManager = @import("sceneManager.zig");


const Self = @This();

const STRING = "noalias source";

pub fn Start() !void {
    Memory.initAllocator();
    defer Memory.deinitAllocator();

    const fConfig = try std.fs.cwd().createFile("config", .{});
    defer fConfig.close();
    const fWriter = fConfig.writer();

    //const stdout = std.io.getStdOut().writer();
    var config = Config.Config.init(Memory.Allocator);

    const string = try Memory.Allocator.alloc(u8, STRING.len);
    @memcpy(string, STRING);

    try config.add("Framerate", @as(u64, 64));

    try config.write(fWriter);

    
    rl.initWindow(Common.Width, Common.Height, Common.Title);
    defer rl.closeWindow();
    
    //Variables like settings and UI textures
    Common.initVariables();
    defer Common.deinitVariables();

    rl.setTargetFPS(Common.Framerate);
    rl.setExitKey(.key_null);
    var scene = try sceneManager.init();
    while (!rl.windowShouldClose() and try scene.loop()) {}
}
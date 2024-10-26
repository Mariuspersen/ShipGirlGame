const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const Memory = @import("memory.zig");
const sceneManager = @import("sceneManager.zig");
const Config = @import("config.zig");

const Self = @This();

const STRING = "noalias source";

pub fn Start() !void {
    Memory.initAllocator();
    defer Memory.deinitAllocator();

    try Config.init(Memory.Allocator);
    defer Config.vars.deinit() catch {};

    rl.initWindow(
        Config.vars.get(i32, "WindowWidth"),
        Config.vars.get(i32, "WindowHeight"),
        Config.vars.get([:0]const u8, "WindowTitle"),
    );
    defer rl.closeWindow();

    //Variables like settings and UI textures
    try Common.initVariables();
    defer Common.deinitVariables();

    var scene = try sceneManager.init();
    while (!rl.windowShouldClose() and try scene.loop()) {}
}

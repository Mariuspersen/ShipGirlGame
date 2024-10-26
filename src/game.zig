const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const Memory = @import("memory.zig");
const sceneManager = @import("sceneManager.zig");

const Self = @This();

const STRING = "noalias source";

pub fn Start() !void {
    Memory.initAllocator();
    defer Memory.deinitAllocator();

    rl.initWindow(Common.Width, Common.Height, Common.Title);
    defer rl.closeWindow();

    //Variables like settings and UI textures
    try Common.initVariables();
    defer Common.deinitVariables();

    var scene = try sceneManager.init();
    while (!rl.windowShouldClose() and try scene.loop()) {}
}

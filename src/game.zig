const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const sceneManager = @import("sceneManager.zig");

const Self = @This();

pub fn Start() !void {
    rl.initWindow(Common.Width, Common.Height, Common.Title);
    defer rl.closeWindow();
    
    //Game uses a different type of allocator
    //depending on build type
    //Release = Arena, Debug = GeneralPurposeAllocator
    Common.initAllocator();
    defer Common.deinitAllocator();

    //Variables like settings and UI textures
    Common.initVariables();
    defer Common.deinitVariables();

    rl.setTargetFPS(Common.Framerate);
    rl.setExitKey(.key_null);
    var scene = try sceneManager.init();
    while (!rl.windowShouldClose() and try scene.loop()) {}
}
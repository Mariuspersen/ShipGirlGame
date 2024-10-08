const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const sceneManager = @import("sceneManager.zig");

const Self = @This();

pub fn Start() !void {
    rl.initWindow(Common.Width, Common.Height, Common.Title);
    Common.initResolution();
    if (Common.Fullscreen) {
        rl.toggleFullscreen();
    }
    defer rl.closeWindow();

    rl.setTargetFPS(Common.Framerate);
    rl.setExitKey(.key_null);
    var scene = try sceneManager.init();
    while (!rl.windowShouldClose() and try scene.loop()) {}
}
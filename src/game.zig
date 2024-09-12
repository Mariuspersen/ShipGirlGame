const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const sceneManager = @import("sceneManager.zig");

const Self = @This();

const Width = Common.Width;
const Height = Common.Height;
const Title = Common.Title;


pub fn Start() !void {
    rl.initWindow(Width, Height, Title);
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    
    var scene = sceneManager.init();
    while (!rl.windowShouldClose() and scene.loop()) {}
}
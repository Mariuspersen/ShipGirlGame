const rl = @import("raylib");
const Common = @import("common.zig");
const Assets = @import("assets.zig");
const Colors = @import("colors.zig");
const sceneList = @import("sceneList.zig").sceneList;

const std = @import("std");
const math = std.math;

const Self = @This();

time: f32,
looping: bool,
nextScene: sceneList,

pub fn load() Self {
    rl.setTargetFPS(60);
    return .{ 
        .time = 0.0,
        .looping = true,
        .nextScene = sceneList.MainMenu,
    };
}

pub fn unload(self: *Self) void {
    _ = self;
}

pub fn loop(self: *Self) void {
    rl.beginDrawing();
    defer rl.endDrawing();
    defer rl.clearBackground(rl.Color.black);

    self.time += rl.getFrameTime();
    const alpha = Common.fade(self.time, 2.0, 7.0, 1.0);
    const color = rl.fade(rl.Color.white, alpha);

    rl.drawText(
        "Made by Marius",
        5,
        5,
        Common.MenuTitleFontSize,
        color,
    );

    if (self.time > 10.0) {
        self.looping = false;
    }
}




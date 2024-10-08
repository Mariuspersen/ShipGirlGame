const rl = @import("raylib");
const Common = @import("common.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;

const Menu = @import("menu.zig");


const std = @import("std");
const math = std.math;

const Self = @This();
const SUSTAIN = 2;
const FADE = 1;
const TEXT = "Made by Marius";

time: f32,

pub fn load() Self {
    return .{
        .time = 0.0,
    };
}

pub fn unload(self: *Self) void {
    _ = self;
}

pub fn loop(self: *Self) !Result {
    var retValue: Result = Result.loop;
    defer rl.clearBackground(rl.Color.black);

    self.time += rl.getFrameTime();
    const alpha = Common.fade(self.time, FADE, SUSTAIN, FADE);
    const color = rl.fade(rl.Color.white, alpha);

    const offset = @divTrunc(rl.measureText(TEXT, Common.MenuTitleFontSize), 2);
    rl.drawText(
        TEXT,
        @divTrunc(Common.Width, 2) - offset,
        @divTrunc(Common.Height, 2) - Common.MenuTitleFontSize,
        Common.MenuTitleFontSize,
        color,
    );

    if (self.time > SUSTAIN + FADE + FADE) {
        retValue = try Result.ok(.MainMenu);
    }
    return retValue;
}

const rl = @import("raylib");
const Common = @import("common.zig");
const Assets = @import("assets.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;

const Menu = @import("menu.zig");


const std = @import("std");
const math = std.math;

const Self = @This();

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
        retValue = try Result.ok(.MainMenu);
    }
    return retValue;
}

const rl = @import("raylib");
const Common = @import("common.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Scenes = @import("sceneManager.zig");
const Config = @import("config.zig");

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

pub fn loop(self: *Self) !void {
    defer rl.clearBackground(rl.Color.black);

    self.time += rl.getFrameTime();
    const alpha = Common.fade(self.time, FADE, SUSTAIN, FADE);
    const color = rl.fade(rl.Color.white, alpha);

    const fontSize = Config.get(i32, "MenuTitleFontSize");

    const offset = @divTrunc(rl.measureText(TEXT, fontSize), 2);
    const width = Config.get(i32, "WindowWidth");
    const height = Config.get(i32, "WindowHeight");
    rl.drawText(
        TEXT,
        @divTrunc(width, 2) - offset,
        @divTrunc(height, 2) - fontSize,
        fontSize,
        color,
    );

    if (self.time > SUSTAIN + FADE + FADE) {
        try Scenes.changeScene(.MainMenu);
    }
}

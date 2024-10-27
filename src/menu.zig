const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const Common = @import("common.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;
const Intro = @import("intro.zig");
const Config = @import("config.zig");

const Self = @This();

background: rl.Texture2D,
time: f32,

pub fn load() !Self {
    var temp = .{
        .background = Assets.battleOcean.getTexture(),
        .time = 0.0,
    };

    temp.background.height = Config.vars.get(i32, "WindowHeight");
    temp.background.width = Config.vars.get(i32, "WindowWidth");
    return temp;
}

pub fn unload(self: *Self) void {
    self.background.unload();
}

pub fn loop(self: *Self) !Result {
    var retValue: Result = Result.loop;

    defer rl.clearBackground(Colors.Gray);
    self.time += rl.getFrameTime();

    //Texture Background
    rl.drawTexture(self.background, 0, 0, rl.Color.white);

    const fontSize = Config.vars.get(i32, "MenuTitleFontSize");
    const title = Config.vars.get([:0]const u8, "WindowTitle");
    const height = Config.vars.get(i32, "WindowHeight");
    const width = Config.vars.get(i32, "WindowWidth");

    //Title Text
    const offset = @divTrunc(rl.measureText(
        title,
        fontSize,
    ), 2);
    rl.drawText(
        title,
        @divTrunc(width, 2) - offset,
        @divTrunc(height, 4),
        fontSize,
        Colors.WhiteGray,
    );

    const rectangle = rl.Rectangle.init(
        (@as(f32, @floatFromInt(width)) / 2.0) - 200.0,
        @as(f32, @floatFromInt(height)) / 3.0,
        400,
        200,
    );
    const play_btn = rg.guiButton(rectangle, "Play");

    if (play_btn == 1) {
        retValue = try Result.ok(.Base);
    }

    //Intro Fade
    const alpha = Common.fade(self.time, 0, 0, 3.0);
    const fade_in_color = rl.fade(rl.Color.black, alpha);
    defer rl.drawRectangle(0, 0, width, height, fade_in_color);

    if (try Common.drawTitleBar()) {
        retValue = try Result.ok(.Quit);
    }

    try Common.checkWindowResized();

    return retValue;
}

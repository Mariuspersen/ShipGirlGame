const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const Common = @import("common.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;
const Intro = @import("intro.zig");

const Self = @This();

background: rl.Texture2D,
time: f32,

pub fn load() Self {
    var temp = .{
        .background = Assets.battleOcean.getTexture(),
        .time = 0.0,
    };

    temp.background.height = Common.Height;
    temp.background.width = Common.Width;
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

    //Title Text
    const offset = @divTrunc(rl.measureText(Common.Title, Common.MenuTitleFontSize), 2);
    rl.drawText(
        Common.Title,
        @divTrunc(Common.Width, 2) - offset,
        @divTrunc(Common.Height, 4),
        Common.MenuTitleFontSize,
        Colors.WhiteGray,
    );

    const rectangle = rl.Rectangle.init(
        (@as(f32, @floatFromInt(Common.Width)) / 2.0) - 200.0,
        @as(f32, @floatFromInt(Common.Height)) / 3.0,
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
    defer rl.drawRectangle(0, 0, Common.Width, Common.Height, fade_in_color);

    if (Common.drawTitleBar()) {
        retValue = try Result.ok(.Quit);
    }

    return retValue;
}

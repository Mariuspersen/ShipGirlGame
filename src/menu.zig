const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const Common = @import("common.zig");
const Assets = @import("assets.zig");
const Colors = @import("colors.zig");
const sceneList = @import("sceneList.zig").sceneList;

const Self = @This();

background: rl.Texture2D,
looping: bool,
nextScene: sceneList,
time: f32,

pub fn load() Self {
    var temp = .{
        .background = Assets.battleOcean.getTexture(),
        .looping = true,
        .nextScene = undefined,
        .time = 0.0,
    };

    temp.background.height = Common.Height;
    temp.background.width = Common.Width;
    return temp;
}

pub fn unload(self: *Self) void {
    self.background.unload();
}

pub fn loop(self: *Self) void {
    rl.beginDrawing();
    defer rl.endDrawing();
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

    const rectangle = rl.Rectangle.init(@divTrunc(Common.Width, 2) - 200, @divTrunc(Common.Height, 3), 400, 200);
    const play_btn = rg.guiButton(rectangle, "Play");

    if (play_btn == 1) {
        self.looping = false;
    }

    //Intro Fade
    const alpha = Common.fade(self.time, 0, 0, 3.0);
    const fade_in_color = rl.fade(rl.Color.black, alpha);
    defer rl.drawRectangle(0, 0, Common.Width, Common.Height, fade_in_color);
}

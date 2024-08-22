const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const Menu = @import("menu.zig");
const Intro = @import("intro.zig");

const Self = @This();

const Width = Common.Width;
const Height = Common.Height;
const Title = Common.Title;


pub fn Start() !void {
    rl.initWindow(Width, Height, Title);
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    
    var scene = Intro.load();
    while (true) {
        while (!rl.windowShouldClose() and scene.looping) {
            scene.loop();
        }

        if (scene.nextScene) |nextScene| {
            defer scene.unload();
            // TODO: Handle switching scenes
            _ = nextScene;
            break;
        }
        else break;
    }
}
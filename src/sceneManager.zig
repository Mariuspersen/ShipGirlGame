const Self = @This();

const std = @import("std");
const rl = @import("raylib");
const Menu = @import("menu.zig");
const Intro = @import("intro.zig");
const Scene = @import("sceneList.zig").Scene;
const Result = @import("sceneList.zig").Result;
const Common = @import("common.zig");

//TODO: write a scenemanager thats not ass

currentScene: Scene,

pub fn init() !Self {
    return .{
        .currentScene = try Scene.init(Common.StartScene),
    };
}

pub fn loop(self: *Self) !bool {
    rl.beginDrawing();
    defer rl.endDrawing();

    Common.checkWindowResized();

    switch (self.currentScene) {
        .Intro => |*intro| {
            switch (try intro.loop()) {
                .ok => |newScene| self.switchScene(newScene),
                .loop => {},
            }
        },
        .MainMenu => |*menu| {
            switch (try menu.loop()) {
                .ok => |newScene| self.switchScene(newScene),
                .loop => {},
            }
        },
        .Base => |*base| {
            switch (try base.loop()) {
                .ok => |newScene| self.switchScene(newScene),
                .loop => {},
            }
        },
        .Quit => {
            return false;
        },
    }

    return true;
}

pub fn switchScene(self: *Self, newScene: Scene) void {
    switch (self.currentScene) {
        .Intro => |*intro| intro.unload(),
        .MainMenu => |*menu| menu.unload(),
        .Base => |*base| base.unload(),
        .Quit => {},
    }
    self.currentScene = newScene;
}

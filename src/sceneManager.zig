const Self = @This();

const rl = @import("raylib");
const Menu = @import("menu.zig");
const Intro = @import("intro.zig");
const Scene = @import("sceneList.zig").Scene;
const Result = @import("sceneList.zig").Result;

//TODO: write a scenemanager thats not ass

currentScene: Scene,

pub fn init() Self {
    return .{
        .currentScene = Scene.init(.Intro),
    };
}

pub fn loop(self: *Self) bool {
    rl.beginDrawing();
    defer rl.endDrawing();

    switch (self.currentScene) {
        .Intro => |*intro| {
            switch (intro.loop()) {
                .ok => |newScene| self.switchScene(newScene),
                .loop => {},
            }
        },
        .MainMenu => |*menu| {
            switch (menu.loop()) {
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
        .Quit => {},
    }
    self.currentScene = newScene;
}

const Self = @This();

const std = @import("std");
const builtin = @import("builtin");

const rl = @import("raylib");
const Menu = @import("menu.zig");
const Intro = @import("intro.zig");
const Input = @import("input.zig");
const Base = @import("baseScene.zig");
const Common = @import("common.zig");

pub var returnVal: Result = undefined;
const startScene: SceneId = switch (builtin.mode) {
        .Debug => .Base,
        else => .Intro,
};

//TODO: write a scenemanager thats not ass

currentScene: Scene,

pub fn init() !Self {
    returnVal = .loop;
    return .{
        .currentScene = try Scene.init(startScene),
    };
}

pub fn loop(self: *Self) !bool {
    rl.beginDrawing();
    defer rl.endDrawing();

    Input.read();
    defer Input.clear();

    switch (returnVal) {
        .ok => |newScene| self.switchScene(newScene),
        .loop => self.loopScene() catch |err| switch (err) {
            error.quit => return false,
            else => return err,
        },
    }
    return true;
}

fn loopScene(self: *Self) !void {
    switch (self.currentScene) {
        .Intro => |*intro| {
            try intro.loop();
        },
        .MainMenu => |*menu| {
            try menu.loop();
        },
        .Base => |*base| {
            try base.loop();
        },
        .Quit => {
            return error.quit;
        },
    }
}

fn switchScene(self: *Self, newScene: Scene) void {
    switch (self.currentScene) {
        .Intro => |*intro| intro.unload(),
        .MainMenu => |*menu| menu.unload(),
        .Base => |*base| base.unload(),
        .Quit => {},
    }
    self.currentScene = newScene;
    returnVal = .loop;
}

const SceneId = std.meta.Tag(Scene);

pub const Scene = union(enum) {
    Intro: Intro,
    MainMenu: Menu,
    Base: Base,
    Quit: void,

    pub fn init(scene: SceneId) !Scene {
        return switch (scene) {
            .Intro => Scene{ .Intro = Intro.load() },
            .MainMenu => Scene{ .MainMenu = try Menu.load() },
            .Base => Scene{ .Base = try Base.load() },
            .Quit => Scene.Quit,
        };
    }
};

const ResultId = std.meta.Tag(Result);

pub const Result = union(enum) {
    ok: Scene,
    loop: void,

    pub fn ok(scene: SceneId) !@This() {
        return .{ .ok = switch (scene) {
            .Intro => Scene{ .Intro = Intro.load() },
            .MainMenu => Scene{ .MainMenu = try Menu.load() },
            .Base => Scene{ .Base = try Base.load() },
            .Quit => Scene.Quit,
        } };
    }
};

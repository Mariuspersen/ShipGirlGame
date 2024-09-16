const Menu = @import("menu.zig");
const Intro = @import("intro.zig");
const Base = @import("baseScene.zig");

const sceneList = enum {
    Intro,
    MainMenu,
    Base,
    Quit,

};

pub const Scene = union(sceneList) {
    Intro: Intro,
    MainMenu: Menu,
    Base: Base,
    Quit: void,

    pub fn init(scene: sceneList) Scene {
        return switch (scene) {
            .Intro => Scene{ .Intro = Intro.load() },
            .MainMenu => Scene{ .MainMenu = Menu.load()},
            .Base => Scene{ .Base = Base.load()},
            .Quit => Scene.Quit,
        };
    }
};

const ResultTag = enum {
    ok,
    loop,
};

pub const Result = union(ResultTag) {
    ok: Scene,
    loop: void,

    pub fn ok(scene: sceneList) @This() {
        return .{ .ok = switch (scene) {
            .Intro => Scene{ .Intro = Intro.load()},
            .MainMenu => Scene{ .MainMenu = Menu.load()},
            .Base => Scene{ .Base = Base.load()},
            .Quit => Scene.Quit,
        }};
    }
};
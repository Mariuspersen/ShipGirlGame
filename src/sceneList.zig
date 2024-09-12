const Menu = @import("menu.zig");
const Intro = @import("intro.zig");

const sceneList = enum {
    Intro,
    MainMenu,
};

pub const Scene = union(sceneList) {
    Intro: Intro,
    MainMenu: Menu,
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
        }};
    }
};
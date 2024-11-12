const Self = @This();

const std = @import("std");
const builtin = @import("builtin");

const rl = @import("raylib");
const Menu = @import("menu.zig");
const Intro = @import("intro.zig");
const Input = @import("input.zig");
const Base = @import("baseScene.zig");
const Common = @import("common.zig");
const Console = @import("console.zig");

var returnVal: Result = undefined;
const startScene: SceneId = switch (builtin.mode) {
    .Debug => .Base,
    else => .Intro,
};

//TODO: write a scenemanager thats not ass

currentScene: Scene,
console: Console,
consoleKey: Input.Macro,

pub fn init() !Self {
    returnVal = .loop;
    return .{
        .consoleKey = try Input.getKeyBind("console"),
        .currentScene = try Scene.init(startScene),
        .console = try Console.init(),
    };
}

pub fn loop(self: *Self) !bool {
    rl.beginDrawing();
    defer rl.endDrawing();

    Input.read();
    defer Input.clear();

    if (self.consoleKey.handleMacro()) {
        self.console.enabled = !self.console.enabled;
    }

    defer self.console.draw();

    switch (returnVal) {
        .ok => |newScene| try self.switchScene(newScene),
        .loop => self.loopScene() catch |err| switch (err) {
            error.quit => return false,
            else => return err,
        },
    }
    return true;
}

fn loopScene(self: *Self) !void {
    switch (self.currentScene) {
        .Quit => {
            return error.quit;
        },
        //Comptime expand the switch
        inline else => |*s| try Scene.loopInner(s),
    }
}

fn switchScene(self: *Self, newScene: Scene) !void {
    switch (self.currentScene) {
        .Quit => {},
        inline else => |*s| try Scene.unloadInner(s),
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
            .Quit => Scene.Quit,
            //Comptime expand the switch
            inline else => |s| loadInner(s),
        };
    }

    pub fn loadInner(comptime scene: SceneId) !Scene {
        const field = std.meta.fieldInfo(Scene, scene);

        // Check to ensure the type has a `load` function.
        if (!std.meta.hasFn(field.type, "load")) {
            @compileError("Type does not have a load function!");
        }

        // Call the `load` function on the type associated with the scene variant.
        const loaded = field.type.load();

        // Check if the loaded type is an error union and handle it accordingly.
        return switch (@typeInfo(@TypeOf(loaded))) {
            .ErrorUnion => @unionInit(Scene, field.name, try loaded),
            else => @unionInit(Scene, field.name, loaded),
        };
    }

    pub fn unloadInner(scene: anytype) !void {
        {
            // Check to ensure the type has a `unload` function.
            if (!std.meta.hasFn(@TypeOf(scene.*), "unload")) {
                @compileError("Type does not have a unload function!");
            }

            //Run the loop function
            const unloaded = scene.unload();

            // Check if the loaded type is an error union and handle it accordingly.
            switch (@typeInfo(@TypeOf(unloaded))) {
                .ErrorUnion => try unloaded,
                else => unloaded,
            }
        }
    }

    pub fn loopInner(scene: anytype) !void {
        // Check to ensure the type has a `loop` function.
        if (!std.meta.hasFn(@TypeOf(scene.*), "loop")) {
            @compileError("Type does not have a loop function!");
        }

        //Run the loop function
        const looped = scene.loop();

        // Check if the loaded type is an error union and handle it accordingly.
        return switch (@typeInfo(@TypeOf(looped))) {
            .ErrorUnion => try looped,
            else => looped,
        };
    }
};

const ResultId = std.meta.Tag(Result);

pub fn SceneIdfromText(text: []const u8) !SceneId {
    inline for (@typeInfo(SceneId).Enum.fields) |field| {
        if (std.mem.eql(u8, text, field.name)) {
            return @enumFromInt(field.value);
        }
    }
    return error.InvalidSceneId;
}

pub const Result = union(enum) {
    ok: Scene,
    loop: void,

    pub fn ok(scene: SceneId) !@This() {
        return .{
            .ok = switch (scene) {
                .Quit => Scene.Quit,
                //Comptime expand the switch
                inline else => |s| try Scene.loadInner(s),
            },
        };
    }
};

pub fn changeScene(id: SceneId) !void {
    returnVal = try Result.ok(id);
}

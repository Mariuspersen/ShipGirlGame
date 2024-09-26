const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const builtin = @import("builtin");

const Common = @import("common.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;
const Intro = @import("intro.zig");

const Self = @This();
const Asset = Assets.Asset;

skybox: Asset,
assets: Assets.AssetList,
debug: bool = switch (builtin.mode) {
    .Debug => true,
    else => false,
},
camera: rl.Camera3D = undefined,
time: f32,

pub fn load() !Self {
    rl.disableCursor();
    var temp = Self{
        .skybox = try Asset.init(&Assets.skySunset, 16.0, 16.0, 16.0),
        .assets = Assets.AssetList.init(Common.allocator),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
    };

    try temp.assets.append(&Assets.guardHouse, 0.0, 0.0, 0.0);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 5.0);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 7.0);
    try temp.assets.append(&Assets.shed, 5.0, 5.0, 5.0);

    temp.assets.setTransformationMatrix(&Assets.energydrink, 0, 0.0, 0.25, 0.0);
    temp.assets.setTransformationMatrix(&Assets.energydrink, 1, 0.0, 0.005, 0.0);

    temp.camera.position = rl.Vector3.init(10.0, 10.0, 10.0);
    temp.camera.target = rl.Vector3.init(0.0, 0.0, 0.0);
    temp.camera.up = rl.Vector3.init(0.0, 1.0, 0.0);
    temp.camera.fovy = 45.0;
    temp.camera.projection = .camera_perspective;
    return temp;
}

pub fn unload(self: *Self) void {
    rl.enableCursor();
    self.skybox.unloadAndDelete();
    self.assets.deinit();
}

pub fn loop(self: *Self) !Result {
    var retValue: Result = Result.loop;

    switch (rl.getKeyPressed()) {
        .key_escape => {
            retValue = try Result.ok(.Quit);
        },
        .key_f3 => {
            self.debug = !self.debug;
        },
        .key_null => {},
        else => |k| {
            if (self.debug) {
                std.debug.print("INFO: KEYPRESS: {any}\n", .{k});
            }
        }
    }

    rl.clearBackground(rl.Color.gray);
    rl.updateCamera(&self.camera, .camera_free);
    rl.beginMode3D(self.camera);

    //Always render the skybox behind
    self.skybox.drawSkybox(&self.camera);
    for (self.assets.arrayList.items) |*asset| {
        asset.draw();
        asset.applyTransformation();
    }
    rl.drawGrid(20, 1.0);
    rl.endMode3D();

    if (self.debug) {
        try Common.drawDebugInfo(&self.camera);
    }

    return retValue;
}



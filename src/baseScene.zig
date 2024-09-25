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
const Asset = Assets.Asset;

skybox: Asset,
assets: std.ArrayList(Asset),
camera: rl.Camera3D = undefined,
time: f32,

pub fn load() !Self {
    rl.disableCursor();
    var temp = Self{
        .skybox = try Asset.init(&Assets.skySunset, 16.0, 16.0, 16.0),
        .assets = std.ArrayList(Asset).init(Common.allocator),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
    };

    try temp.assets.append(try Asset.init(&Assets.guardHouse, 0.0, 0.0, 0.0));
    try temp.assets.append(try Asset.init(&Assets.energydrink, 0.0, 7.0, 5.0));
    try temp.assets.append(try Asset.init(&Assets.shed, 5.0, 5.0, 5.0));

    temp.camera.position = rl.Vector3.init(10.0, 10.0, 10.0);
    temp.camera.target = rl.Vector3.init(0.0, 0.0, 0.0);
    temp.camera.up = rl.Vector3.init(0.0, 1.0, 0.0);
    temp.camera.fovy = 45.0;
    temp.camera.projection = .camera_perspective;
    return temp;
}

pub fn unload(self: *Self) !void {
    rl.enableCursor();
    try self.skybox.unloadAndDelete();
    for (self.assets.items) |asset| {
        try asset.unloadAndDelete();
    }
    self.assets.deinit();
}

pub fn loop(self: *Self) !Result {
    var retValue: Result = Result.loop;
    const key = rl.getKeyPressed();
    rl.clearBackground(rl.Color.gray);
    rl.updateCamera(&self.camera, .camera_free);
    rl.beginMode3D(self.camera);

    
    //Always render the skybox behind
    self.skybox.drawSkybox(&self.camera);
    for (self.assets.items) |asset| {
        asset.draw();
    }
    rl.drawGrid(20, 1.0);
    rl.endMode3D();

    rl.drawFPS(0, 0);
    Common.drawVersionNumber();

    const position: [:0]u8 = try std.fmt.allocPrintZ(Common.allocator, "{any}", .{self.camera.position});
    defer Common.allocator.free(position);
    rl.drawText(position, 10, 10, 20, rl.Color.white);

    if (key == .key_escape) {
        retValue = try Result.ok(.Quit);
    }

    return retValue;
}

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

box: rl.Model,
boxpos: rl.Vector3,
shed: rl.Model,
shedpos: rl.Vector3,
sky: rl.Model = undefined,
skypos: rl.Vector3,
base: rl.Model,
basepos: rl.Vector3,
background: rl.Texture2D,
camera: rl.Camera3D = undefined,
time: f32,

pub fn load() !Self {
    var temp = Self{
        .box = try Assets.box.getModel(),
        .boxpos = rl.Vector3.init(0.0, 0.0, 0.0),
        .shed = try Assets.shed.getModel(),
        .shedpos = rl.Vector3.init(-5.0, 5.0, 5.0),
        .sky = try Assets.skySunset.getModel(),
        .skypos = rl.Vector3.init(16.0, 16.0, 16.0),
        .base = try Assets.base.getModel(),
        .basepos = rl.Vector3.init(0.0, 0.0, 0.0),
        .background = Assets.battleOcean.getTexture(),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
    };


    rl.disableCursor();
    temp.camera.position = rl.Vector3.init(10.0, 10.0, 10.0);
    temp.camera.target = rl.Vector3.init(0.0, 0.0, 0.0);
    temp.camera.up = rl.Vector3.init(0.0, 1.0, 0.0);
    temp.camera.fovy = 45.0;
    temp.camera.projection = .camera_perspective;

    temp.background.height = Common.Height;
    temp.background.width = Common.Width;
    return temp;
}

pub fn unload(self: *Self) !void {
    self.background.unload();
    self.box.unload();
    self.shed.unload();
    self.sky.unload();
    try Assets.shed.deleteRemnants();
    try Assets.box.deleteRemnants();
    try Assets.skySunset.deleteRemnants();
    rl.enableCursor();
}

pub fn loop(self: *Self) !Result {
    var retValue: Result = Result.loop;
    const key = rl.getKeyPressed();
    rl.clearBackground(rl.Color.gray);
    rl.updateCamera(&self.camera, .camera_free);
    rl.beginMode3D(self.camera);

    //Always render the skybox behind
    rl.gl.rlDisableDepthMask();
    rl.drawModel(self.sky, self.camera.position.add(self.skypos), 1.0, rl.Color.white);
    rl.gl.rlEnableDepthMask();

    rl.drawGrid(20, 1.0);
    rl.drawModel(self.base, self.basepos, 1.0, rl.Color.white);
    //rl.drawModel(self.box, self.boxpos, 1.0, rl.Color.white);
    //rl.drawModel(self.shed, self.shedpos, 1.0, rl.Color.white);
    rl.endMode3D();
    rl.drawFPS(0, 0);

    if (key == .key_escape) {
        retValue = try Result.ok(.Quit);
    }

    return retValue;
}

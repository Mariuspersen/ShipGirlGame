const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const Common = @import("common.zig");
const Assets = @import("assets.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;
const Intro = @import("intro.zig");

const Self = @This();

boxes: rl.Model,
boxpos: rl.Vector3,
boxbounds: rl.BoundingBox = undefined,
background: rl.Texture2D,
camera: rl.Camera3D = undefined,
time: f32,

pub fn load() Self {
    var temp = Self{
        .boxes = Assets.boxes.getModel(),
        .boxpos = rl.Vector3.init(0.0, 0.0, 0.0),
        .background = Assets.battleOcean.getTexture(),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
    };

    temp.boxes.materials[0].maps[@intFromEnum(rl.MATERIAL_MAP_DIFFUSE)].texture = Assets.tileset.getTexture();
    temp.boxbounds = rl.getMeshBoundingBox(temp.boxes.meshes[0]);

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

pub fn unload(self: *Self) void {
    self.background.unload();
    self.boxes.unload();
    rl.enableCursor();
}

pub fn loop(self: *Self) Result {
    const retValue: Result = Result.loop;
    rl.clearBackground(rl.Color.ray_white);
    rl.updateCamera(&self.camera, .camera_free);

    rl.beginMode3D(self.camera);
    rl.drawModel(self.boxes, self.boxpos, 1.0, rl.Color.white);
    rl.endMode3D();
    return retValue;
}

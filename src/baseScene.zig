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
const Light = @import("lights.zig");

const Self = @This();
const Asset = Assets.Asset;

skybox: Asset,
light: Light = undefined,
shader: rl.Shader,
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
        .skybox = try Asset.init(&Assets.skySunset, -16.0, -16.0, -16.0, &Common.Zero),
        .assets = Assets.AssetList.init(Common.allocator),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
        .shader = Assets.lighting.loadShader(),
    };

    temp.shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)] = rl.getShaderLocation(
        temp.shader,
        "viewPos",
    );
    const loc = rl.getShaderLocation(temp.shader, "ambient");

    rl.setShaderValue(
        temp.shader,
        loc,
        &[4]f32{ 0.1, 0.1, 0.1, 1.0 },
        rl.ShaderUniformDataType.shader_uniform_vec4,
    );

    temp.light = Light.CreateLight(
        .LIGHT_POINT,
        rl.Vector3.init(1.0, 1.0, 1.0),
        rl.Vector3.init(0.0, 0.0, 0.0),
        rl.Color.fromInt(0xfcf185FF),
        temp.shader,
    );

    try temp.assets.append(&Assets.guardHouse, -20, 19.5, -2.5);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 5.0);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 7.0);
    try temp.assets.append(&Assets.shed, 5.0, 5.0, 5.0);
    try temp.assets.append(&Assets.draug, 30.0, 5.0, 10);

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
    rl.unloadShader(self.shader);
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
        .key_f4 => {
            std.debug.print("{any}\n", .{self.light});
            std.debug.print("{any}\n", .{self.shader});
            self.light.enabled = !self.light.enabled;
        },
        .key_null => {},
        else => |k| {
            if (self.debug) {
                std.debug.print("INFO: KEYPRESS: {any}\n", .{k});
            }
        },
    }

    rl.clearBackground(rl.Color.gray);
    rl.updateCamera(&self.camera, .camera_free);
    self.light.updateLightValues(self.shader);
    rl.setShaderValue(
        self.shader,
        self.shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)],
        &[3]f32{ self.camera.position.x, self.camera.position.y, self.camera.position.z },
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );
    {
        rl.beginMode3D(self.camera);
        defer rl.endMode3D();
        //Always render the skybox behind
        self.skybox.drawSkybox(&self.camera);
        self.shader.activate();
        defer self.shader.deactivate();

        for (self.assets.arrayList.items) |*asset| {
            asset.draw();
            asset.applyTransformation();
        }

        rl.drawCube(rl.Vector3.zero(), 1.0, 1.0, 1.0, rl.Color.white);
        rl.drawGrid(100, 1.0);
    }

    if (self.debug) {
        try Common.drawDebugInfo(&self.camera);
    }

    return retValue;
}

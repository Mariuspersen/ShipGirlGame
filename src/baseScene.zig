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

    temp.shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_matrix_model)] = rl.getShaderLocation(
        temp.shader,
        "matModel",
    );

    const ambientLoc = rl.getShaderLocation(temp.shader, "ambient");
    const ambientColor = rl.Color.fromInt(0x19071DFF);
    rl.setShaderValue(
        temp.shader,
        ambientLoc,
        &rl.Vector4.init(
        @as(f32, @floatFromInt(ambientColor.r)) / 255.0,
        @as(f32, @floatFromInt(ambientColor.g)) / 255.0,
        @as(f32, @floatFromInt(ambientColor.b)) / 255.0,
        @as(f32, @floatFromInt(ambientColor.a)) / 255.0,
        ),
        rl.ShaderUniformDataType.shader_uniform_vec4,
    );

    temp.light = Light.CreateLight(
        Light.DIRECTIONAL,
        rl.Vector3.init(1.0, 1.0, 1.0),
        rl.Vector3.init(0.0, 0.0, 0.0),
        rl.Color.fromInt(0xFFAAFFFF),
        temp.shader,
    );

    try temp.assets.append(&Assets.guardHouse, -20, 19.5, -2.5);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 5.0);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 7.0);
    try temp.assets.append(&Assets.shed, 5.0, 5.0, 5.0);
    try temp.assets.append(&Assets.draug, 30.0, 5.0, 10);

    temp.assets.setTransformationMatrix(&Assets.energydrink, 0, 0.0, 0.25, 0.0);
    temp.assets.setTransformationMatrix(&Assets.energydrink, 1, 0.0, 0.005, 0.0);

    for (temp.assets.arrayList.items) |*asset| {
        for (0..@as(usize, @intCast(asset.model.materialCount))) |i| {
            asset.model.materials[i].shader = temp.shader;
        }
    }

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
            self.light.enabled = if (self.light.enabled == 1) 0 else 1;
            std.debug.print("{any}\n", .{self.light});
            std.debug.print("{any}\n", .{self.shader});
            std.debug.print("{d}\n", .{Light.MAX_LIGHTS});
        },
        .key_f11 => {
            rl.toggleFullscreen();
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
    rl.setShaderValue(
        self.shader,
        self.shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)],
        &[3]f32{ self.camera.position.x, self.camera.position.y, self.camera.position.z },
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );
    self.light.updateLightValues(self.shader);
    //Draw 3D objects
    rl.beginMode3D(self.camera);
    //Always render the skybox behind
    self.skybox.drawSkybox(&self.camera);
    //Shadows shader
    self.shader.activate();

    //Draw objects and apply effects
    for (self.assets.arrayList.items) |*asset| {
        asset.draw();
        asset.applyTransformation();
    }

    self.shader.deactivate();
    rl.drawGrid(100, 1.0);
    rl.endMode3D();

    if (self.debug) {
        try Common.drawDebugInfo(&self.camera);
    }

    return retValue;
}

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const builtin = @import("builtin");

const Common = @import("common.zig");
const Memory = @import("memory.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Result = @import("sceneList.zig").Result;
const Scene = @import("sceneList.zig").Scene;
const Intro = @import("intro.zig");
const Light = @import("lights.zig");
const Ocean = @import("ocean.zig");

const Self = @This();
const Asset = Assets.Asset;

skybox: Asset,
lights: [Light.MAX_LIGHTS]Light,
lightShader: rl.Shader,
oceanShader: rl.Shader,
ocean: Ocean = undefined,
assets: Assets.AssetList,
debug: bool = switch (builtin.mode) {
    .Debug => true,
    else => false,
},
camera: rl.Camera3D = undefined,
time: f32,

pub fn load() !Self {
    //rl.disableCursor();
    var temp = Self{
        .skybox = try Asset.init(&Assets.skySunset, -16.0, -16.0, -16.0, &Common.Zero),
        .assets = Assets.AssetList.init(Memory.Allocator),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
        .lightShader = Assets.lighting.loadShader(),
        .oceanShader = Assets.ocean.loadShader(),
        .lights = std.mem.zeroes([Light.MAX_LIGHTS]Light),
    };

    temp.ocean = Ocean.init(temp.oceanShader);

    temp.lightShader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)] = rl.getShaderLocation(
        temp.lightShader,
        "viewPos",
    );

    temp.lightShader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_matrix_model)] = rl.getShaderLocation(
        temp.lightShader,
        "matModel",
    );

    const ambientLoc = rl.getShaderLocation(temp.lightShader, "ambient");
    const ambientColor = rl.Color.fromInt(0x654801FF);
    rl.setShaderValue(
        temp.lightShader,
        ambientLoc,
        &rl.Vector4.init(
            @as(f32, @floatFromInt(ambientColor.r)) / 255.0,
            @as(f32, @floatFromInt(ambientColor.g)) / 255.0,
            @as(f32, @floatFromInt(ambientColor.b)) / 255.0,
            @as(f32, @floatFromInt(ambientColor.a)) / 255.0,
        ),
        rl.ShaderUniformDataType.shader_uniform_vec4,
    );

    temp.lights[Light.LIGHT_COUNT] = try Light.CreateLight(
        Light.DIRECTIONAL,
        rl.Vector3.init(1.0, 1.0, 1.0),
        rl.Vector3.init(0.0, 0.0, 0.0),
        rl.Color.fromInt(0xfde198ff),
        temp.lightShader,
    );

    temp.lights[Light.LIGHT_COUNT] = try Light.CreateLight(
        Light.POINT,
        rl.Vector3.init(0.8, 7.1, 6.0),
        rl.Vector3.init(0.0, 7.0, 7.0),
        rl.Color.fromInt(0x00110011),
        temp.lightShader,
    );

    try temp.assets.append(&Assets.guardHouse, -20, 19.5, -2.5);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 5.0);
    try temp.assets.append(&Assets.energydrink, 0.0, 7.0, 7.0);
    //try temp.assets.append(&Assets.shed, 5.0, 5.0, 5.0);
    try temp.assets.append(&Assets.draug, 30.0, 5.0, 10);

    temp.assets.setTransformationMatrix(&Assets.energydrink, 0, 0.0, 0.25, 0.0);
    temp.assets.setTransformationMatrix(&Assets.energydrink, 1, 0.0, 0.005, 0.0);

    for (temp.assets.arrayList.items) |*asset| {
        for (0..@as(usize, @intCast(asset.model.materialCount))) |i| {
            asset.model.materials[i].shader = temp.lightShader;
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
    for (self.lights) |light| {
        light.DestroyLight();
    }
    rl.unloadShader(self.lightShader);
    rl.unloadShader(self.oceanShader);
}

pub fn loop(self: *Self) !Result {
    var retValue: Result = Result.loop;
    const ctrlDown = rl.isKeyDown(.key_left_control);
    //TODO: Make keyboard handling into a manager to handle input universally
    if (ctrlDown) {
        if (rl.isCursorHidden()) {
            rl.enableCursor();
            rl.showCursor();
        }
    } else {
        if (!rl.isCursorHidden()) {
            rl.hideCursor();
            rl.disableCursor();
        }
    }

    switch (rl.getKeyPressed()) {
        .key_escape => {
            retValue = try Result.ok(.Quit);
        },
        .key_f3 => {
            self.debug = !self.debug;
        },
        .key_f4 => {
            inline for (&self.lights) |*light| {
                light.enabled = if (light.enabled == 1) 0 else 1;
            }
        },
        .key_f11 => {
            Common.toggleFullscreen();
        },
        .key_null => {},
        else => |k| {
            if (self.debug) {
                std.debug.print("INFO: KEYPRESS: {any}\n", .{k});
            }
        },
    }
    rl.clearBackground(rl.Color.gray);

    if (!ctrlDown) {
        rl.updateCamera(&self.camera, .camera_free);
    }

    rl.setShaderValue(
        self.lightShader,
        self.lightShader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)],
        &self.camera.position,
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );

    inline for (self.lights) |light| {
        light.updateLightValues(self.lightShader);
    }
    //Draw 3D objects
    rl.beginMode3D(self.camera);
    //Always render the skybox behind
    self.skybox.drawSkybox(&self.camera);
    //Shadows shader
    self.lightShader.activate();

    //Draw objects and apply effects
    for (self.assets.arrayList.items) |*asset| {
        asset.draw();
        asset.applyTransformation();
    }

    self.lightShader.deactivate();

    self.ocean.update();
    self.oceanShader.activate();
    rl.drawPlane(rl.Vector3.zero(), rl.Vector2.init(10, 10), rl.Color.white);
    self.oceanShader.deactivate();
    rl.drawGrid(100, 1.0);
    rl.endMode3D();

    if (self.debug) {
        try Common.drawDebugInfo(&self.camera);
    }

    if (Common.drawCloseBtn()) {
        retValue = try Result.ok(.MainMenu);
    }

    return retValue;
}

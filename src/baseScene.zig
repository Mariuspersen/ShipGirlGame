const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const builtin = @import("builtin");

const Common = @import("common.zig");
const Config = @import("config.zig");
const Memory = @import("memory.zig");
const Assets = @import("assetManager.zig");
const Colors = @import("colors.zig");
const Scenes = @import("sceneManager.zig");
const Intro = @import("intro.zig");
const Light = @import("lights.zig");
const Ocean = @import("ocean.zig");
const Input = @import("input.zig");

const Self = @This();
const Asset = Assets.Asset;
const AssetList = Assets.AssetList;

var amp: f32 = 0.25;
var freq: f32 = 0.25;

skybox: Asset,
lights: [Light.MAX_LIGHTS]Light,
lightShader: rl.Shader,
ocean: Ocean = undefined,
oceanShader: rl.Shader,
assets: Assets.AssetList,
debug: bool = switch (builtin.mode) {
    .Debug => true,
    else => false,
},
camera: rl.Camera3D = undefined,
time: f32,

pub fn load() !Self {
    var temp = Self{
        .skybox = try Asset.init(&Assets.skySunset, -16.0, -16.0, -16.0, 0),
        .assets = AssetList.init(Memory.Allocator),
        .camera = std.mem.zeroInit(rl.Camera3D, .{}),
        .time = 0.0,
        .lightShader = Assets.lighting.loadShader(),
        .lights = std.mem.zeroes([Light.MAX_LIGHTS]Light),
        .oceanShader = Assets.ocean.loadShader(),
    };

    //Weird bug where a black bar around the window appears
    //Is this a raylib issue? No clue!
    //Common.windowConfigFlags.window_undecorated = true;
    //rl.setWindowState(Common.windowConfigFlags);

    temp.ocean = try Ocean.init(temp.oceanShader);

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

    try Config.add("TitleBarOffset", @as(i32, 0));

    try temp.assets.append(&Assets.guardHouse, -20, 21.5, -2.5);
    try temp.assets.append(&Assets.energydrink, 0.0, 8.0, 5.0);
    try temp.assets.append(&Assets.energydrink, 0.0, 8.0, 7.0);
    try temp.assets.append(&Assets.sandIsland, 0.0, 2.0, 0.0);
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

    try Config.add("TitleBarOffset", @as(i32, 46));
    return temp;
}

pub fn unload(self: *Self) void {
    rl.enableCursor();
    self.skybox.unloadAndDelete();
    self.assets.deinit();
    for (self.lights) |light| {
        light.DestroyLight();
    }
    self.ocean.deinit();
    rl.memFree(self.lightShader.locs);
    rl.memFree(self.oceanShader.locs);
}

pub fn loop(self: *Self) !void {
    if (Input.modifierKey == .key_left_control) {
        if (rl.isCursorHidden()) {
            rl.enableCursor();
            rl.showCursor();
        }
    } else {
        if (!rl.isCursorHidden()) {
            rl.hideCursor();
            rl.disableCursor();
        }
        rl.updateCamera(&self.camera, .camera_free);
    }

    var macro = try Input.getKeyBind("debug_level");
    if (macro.handleMacro()) {
        self.debug = !self.debug;
    }

    switch (Input.currentKey) {
        .key_escape => {
            try Scenes.changeScene(.MainMenu);
        },
        .key_f4 => {
            inline for (&self.lights) |*light| {
                light.enabled = if (light.enabled == 1) 0 else 1;
            }
        },
        .key_f5 => {
            try Input.setKeyBind("fullscreen", .key_f11, .isKeyPressed);
        },
        .key_f6 => {
            const key = Input.getKeyBind("fullscreen");
            std.debug.print("{any}\n", .{key});
        },
        .key_f11 => {
            try Common.toggleFullscreen();
        },
        .key_null => {},
        else => |k| {
            if (self.debug) {
                std.debug.print("INFO: KEYPRESS: {any}\n", .{k});
            }
        },
    }
    rl.clearBackground(rl.Color.gray);

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

    self.lightShader.activate();
    //Ocean Stuff
    self.ocean.update();
    self.ocean.draw(self.camera);
    //Shadows shader
    //Draw objects and apply effects
    for (self.assets.arrayList.items) |*asset| {
        asset.draw();
        asset.applyTransformation();
    }

    self.lightShader.deactivate();

    rl.drawGrid(100, 1.0);
    rl.endMode3D();

    if (self.debug) {
        try Common.drawDebugInfo(&self.camera);
    }

    if (try Common.drawTitleBar()) {
        try Scenes.changeScene(.MainMenu);
    }

    try Common.checkWindowResized();
}

const std = @import("std");
const builtin = @import("builtin");

const rl = @import("raylib");
const Common = @import("common.zig");

const fs = std.fs;

pub const Asset = struct {
    model: rl.Model,
    hash: u32,
    glb: *const embeddedGLB,
    position: rl.Vector3,
    rotation: ?rl.Matrix = null,
    scale: f32 = 1.0,
    color: rl.Color = rl.Color.white,

    pub fn init(model: *const embeddedGLB, x: f32, y: f32, z: f32, count: *const usize) !Asset {
        try Common.initDrawLoadingMessage(model.name, count);
        return .{
            .model = try model.getModel(),
            .glb = model,
            .position = rl.Vector3.init(x, y, z),
            .hash = std.hash.uint32(@intCast(std.time.timestamp())),
        };
    }

    pub inline fn applyTransformation(self: *Asset) void {
        if (self.rotation) |r| {
            self.model.transform = r.multiply(self.model.transform);
        }
    }

    pub inline fn draw(self: *const Asset) void {
        rl.drawModel(self.model, self.position, self.scale, self.color);
    }

    pub inline fn drawSkybox(self: *const Asset, camera: *rl.Camera3D) void {
        rl.gl.rlDisableDepthMask();
        rl.drawModel(self.model, camera.position.add(self.position), self.scale, self.color);
        rl.gl.rlEnableDepthMask();
    }

    pub inline fn unloadAndDelete(self: *const Asset) void {
        self.model.unload();
        self.glb.deleteRemnants();
    }
};

pub const AssetList = struct {
    arrayList: std.ArrayList(Asset),

    pub fn init(allocator: std.mem.Allocator) AssetList {
        return .{
            .arrayList = std.ArrayList(Asset).init(allocator),
        };
    }

    pub fn append(self: *AssetList, model: *const embeddedGLB, x: f32, y: f32, z: f32) !void {
        try self.arrayList.append(try Asset.init(model, x, y, z, &self.arrayList.items.len));
    }

    pub fn setTransformationMatrix(self: *AssetList, model: *const embeddedGLB, index: ?usize, x: f32, y: f32, z: f32) void {
        var i: usize = 0;
        const rotationMatrix = rl.Matrix.rotateXYZ(rl.Vector3.init(x, y, z));
        for (self.arrayList.items) |*asset| {
            if (asset.glb == model) {
                if (index) |idx| {
                    if (i == idx) {
                        asset.rotation = rotationMatrix;
                    }
                }
                i += 1;
            }
        }
    }

    pub fn deinit(self: *AssetList) void {
        for (self.arrayList.items) |asset| {
            asset.unloadAndDelete();
        }
        self.arrayList.deinit();
    }
};

const embeddedGLB = struct {
    name: [:0]const u8,
    data: []const u8,

    pub fn init(path: []const u8) embeddedGLB {
        return .{
            .name = fs.path.basename(path)[0.. :0],
            .data = @embedFile(path),
        };
    }
    pub fn getModel(self: *const embeddedGLB) !rl.Model {
        const gltfFile = try fs.cwd().createFile(self.name, .{});
        defer gltfFile.close();
        try gltfFile.writeAll(self.data);
        return rl.loadModel(self.name);
    }
    pub fn deleteRemnants(self: *const embeddedGLB) void {
        fs.cwd().deleteFile(self.name) catch |err| {
            std.debug.print("INFO: ASSET: Unable to delete {s} because of {any}\n", .{ self.name, err });
        };
    }
};

const embeddedFile = struct {
    data: []const u8,
    fileType: [:0]const u8,

    pub fn init(path: []const u8) embeddedFile {
        return .{
            .data = @embedFile(path),
            .fileType = fs.path.extension(path)[0.. :0],
        };
    }

    pub fn getTexture(self: *const embeddedFile) rl.Texture2D {
        const image = self.getImage();
        defer image.unload();
        const texture = rl.loadTextureFromImage(image);
        return texture;
    }

    pub fn getImage(self: *const embeddedFile) rl.Image {
        return rl.loadImageFromMemory(self.fileType, self.data);
    }
};

const embeddedShader = struct {
    const VERSION = switch (builtin.os.tag) {
        .linux => "#version 330",
        else => "",
    };
    
    vertex: [:0]const u8,
    fragment: [:0]const u8,

    pub fn init(comptime vertex: []const u8, comptime fragment: []const u8) embeddedShader {
        return .{
            .vertex = VERSION ++ @embedFile(vertex),
            .fragment = VERSION ++ @embedFile(fragment),
        };
    }

    pub fn loadShader(self: *const embeddedShader) rl.Shader {
        return rl.loadShaderFromMemory(self.vertex, self.fragment);
    }

};
//Textures
pub const battleOcean = embeddedFile.init("assets/BattleOcean.png");

//Models
pub const skySunset = embeddedGLB.init("assets/skybox.glb");
pub const guardHouse = embeddedGLB.init("assets/guardhouse.glb");
pub const box = embeddedGLB.init("assets/box.glb");
pub const shed = embeddedGLB.init("assets/shed.glb");
pub const energydrink = embeddedGLB.init("assets/databrus.glb");
pub const draug = embeddedGLB.init("assets/KNM Draug.glb");

//Shaders
pub const lighting = embeddedShader.init("shaders/directional.vs", "shaders/directional.fs");

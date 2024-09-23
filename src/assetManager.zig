const std = @import("std");
const rl = @import("raylib");

const fs = std.fs;

pub const Asset = struct {
    model: rl.Model,
    glb: *const embeddedGLB,
    position: rl.Vector3,
    scale: f32 = 1.0,
    color: rl.Color = rl.Color.white,

    pub fn init(model: *const embeddedGLB, x: f32, y: f32, z: f32) !Asset {
        return .{
            .model = try model.getModel(),
            .glb = model,
            .position = rl.Vector3.init(x, y, z),
        };
    }

    pub inline fn draw(self: *const Asset) void {
        rl.drawModel(self.model, self.position, self.scale, self.color);
    }

    pub inline fn drawSkybox(self: *const Asset, camera: *rl.Camera3D) void {
        rl.gl.rlDisableDepthMask();
        rl.drawModel(self.model, camera.position.add(self.position), self.scale, self.color);
        rl.gl.rlEnableDepthMask();
    }

    pub inline fn unloadAndDelete(self: *const Asset) !void {
        self.model.unload();
        try self.glb.deleteRemnants();
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
    pub fn deleteRemnants(self: *const embeddedGLB) !void {
        try fs.cwd().deleteFile(self.name);
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

pub const battleOcean = embeddedFile.init("assets/BattleOcean.png");
pub const skySunset = embeddedGLB.init("assets/skybox.glb");
pub const guardHouse = embeddedGLB.init("assets/guardhouse.glb");
pub const box = embeddedGLB.init("assets/box.glb");
pub const shed = embeddedGLB.init("assets/shed.glb");

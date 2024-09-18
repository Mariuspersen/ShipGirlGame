const std = @import("std");
const rl = @import("raylib");

const fs = std.fs;

const embeddedGLB = struct {
    name: [:0]const u8,
    data: []const u8,

    pub fn init(path: []const u8) @This() {
        return .{
            .name = fs.path.basename(path)[0..:0],
            .data = @embedFile(path),
        };
    }
    pub fn getModel(self: *const @This()) !rl.Model {
        const gltfFile = try fs.cwd().createFile(self.name, .{});
        defer gltfFile.close();
        try gltfFile.writeAll(self.data);

        return rl.loadModel(self.name);
    }
    pub fn deleteRemnants(self: *const @This()) !void {
        try fs.cwd().deleteFile(self.name);
    }
};

const embeddedFile = struct {
    data: []const u8 ,
    fileType: [:0]const u8,

    pub fn init(path: []const u8) embeddedFile {
        return .{
            .data = @embedFile(path),
            .fileType = fs.path.extension(path)[0..:0],
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
pub const box = embeddedGLB.init("assets/box.glb");
pub const shed = embeddedGLB.init("assets/shed.glb");

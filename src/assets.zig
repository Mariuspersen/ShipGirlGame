const std = @import("std");
const rl = @import("raylib");

const fs = std.fs;

const missingTexturePath = "assets/missing.png";
const missingTexture = @embedFile(missingTexturePath);

const embeddedModel = struct {
    objectSentinel: [*:0]const u8,
    objectName: []const u8,
    objectData: []const u8,
    textureData: []const u8,
    textureType: [*:0]const u8,
    materialData: []const u8,
    materialName: []const u8,

    pub fn init(object: []const u8, texture: []const u8, material: []const u8) embeddedModel {
        return .{
            .objectSentinel = fs.path.basename(object)[0.. :0],
            .objectName = fs.path.basename(object),
            .objectData = @embedFile(object),
            .textureData = @embedFile(texture),
            .textureType = fs.path.extension(texture)[0.. :0],
            .materialName = fs.path.basename(material),
            .materialData = @embedFile(material),
        };
    }
    pub fn getModel(self: *const embeddedModel) !rl.Model {
        const objectFile = try fs.cwd().createFile(self.objectName, .{});
        defer objectFile.close();
        try objectFile.writeAll(self.objectData);

        const materialFile = try fs.cwd().createFile(self.materialName, .{});
        defer materialFile.close();
        try materialFile.writeAll(self.materialData);

        const image = rl.loadImageFromMemory(self.textureType, self.textureData);
        defer image.unload();
        const texture = rl.loadTextureFromImage(image);
        const model = rl.loadModel(self.objectSentinel);

        model.materials[0].maps[@intFromEnum(rl.MATERIAL_MAP_DIFFUSE)].texture = texture;
        return model;
    }

    pub fn deleteRemnants(self: *const embeddedModel) !void {
        try fs.cwd().deleteFile(self.objectName);
        try fs.cwd().deleteFile(self.materialName);
    }
};

const embeddedFile = struct {
    name: []const u8,
    path: [*:0]const u8,
    content: ?[]const u8 = null,
    fileType: [*:0]const u8,

    pub fn init(path: []const u8) embeddedFile {
        var temp = embeddedFile{
            .name = fs.path.basename(path),
            .fileType = fs.path.extension(path)[0.. :0],
            .path = path[0.. :0],
        };
        if (!std.mem.eql(u8, fs.path.extension(path), ".obj")) {
            temp.content = @embedFile(path);
        }
        return temp;
    }

    pub fn getTexture(self: *const embeddedFile) rl.Texture2D {
        const content = self.content orelse missingTexture;
        const image = rl.loadImageFromMemory(self.fileType, content);
        defer image.unload();
        const texture = rl.loadTextureFromImage(image);
        return texture;
    }

    pub fn getImage(self: *const embeddedFile) rl.Image {
        return rl.loadImageFromMemory(self.fileType, self.content);
    }

    pub fn getModel(self: *const embeddedFile) rl.Model {
        return rl.loadModel(self.path);
    }
};

pub const battleOcean = embeddedFile.init("assets/BattleOcean.png");
pub const box = embeddedModel.init(
    "assets/box.obj",
    "assets/texture_0.png",
    "assets/box.mtl",
);

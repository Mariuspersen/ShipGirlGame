const std = @import("std");
const rl = @import("raylib");

const fs = std.fs;

const missingTexture = @embedFile("assets/missing.png");

const embeddedModel = struct {
    object: []const u8,
    texture: [] const u8,
    
    pub fn init(object: []const u8, texture: ?[]const u8) embeddedModel {
        return .{
            .object = object,
            .texture = texture orelse missingTexture
        };
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

pub const battleOcean =  embeddedFile.init("assets/BattleOcean.png");
pub const boxes = embeddedFile.init("assets/boxes.obj");
pub const tileset = embeddedFile.init("assets/texture_0.png");


const std = @import("std");
const rl = @import("raylib");

const fs = std.fs;

const embeddedFile = struct {
    name: []const u8,
    content: []const u8,
    fileType: [*:0]const u8,

    pub fn init(path: []const u8) embeddedFile {
        return .{
            .name = fs.path.basename(path),
            .content = @embedFile(path),
            .fileType = fs.path.extension(path)[0..:0],
        };
    }

    pub fn getTexture(self: *const embeddedFile) rl.Texture2D {
        const image = rl.loadImageFromMemory(self.fileType, self.content);
        defer image.unload();

        const texture = rl.loadTextureFromImage(image);
        return texture;
    }

    pub fn getImage(self: *const embeddedFile) rl.Image {
        return rl.loadImageFromMemory(self.fileType, self.content);
    }
};

pub const battleOcean = embeddedFile.init("assets/BattleOcean.png");
pub const introVideo = embeddedFile.init("assets/intro.mkv");
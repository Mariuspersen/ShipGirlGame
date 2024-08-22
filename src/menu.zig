const rl = @import("raylib");
const Common = @import("common.zig");
const Assets = @import("assets.zig");
const Colors = @import("colors.zig");
const Self = @This();

background: rl.Texture2D,
looping: bool,
nextScene: ?[]const u8,

pub fn load() Self {
    var temp = .{
        .background = Assets.battleOcean.getTexture(),
        .looping = true,
        .nextScene = null,
    };
    temp.background.height = Common.Height;
    temp.background.width = Common.Width;
    return temp;
}

pub fn unload(self: *Self) void {
    self.background.unload();
}

pub fn loop(self: *Self) void {
    rl.beginDrawing();
    defer rl.endDrawing();
    defer rl.clearBackground(Colors.Gray);

    rl.drawTexture(self.background, 0, 0, rl.Color.white);

    const offset = @divTrunc(rl.measureText(Common.Title, Common.MenuTitleFontSize), 2);
    rl.drawText(
        Common.Title,
        @divTrunc(Common.Width, 2) - offset,
        @divTrunc(Common.Height, 4),
        Common.MenuTitleFontSize,
        Colors.WhiteGray,
    );
}

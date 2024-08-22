const rl = @import("raylib");
const Common = @import("common.zig");
const Assets = @import("assets.zig");
const Colors = @import("colors.zig");
const Self = @This();

start: f64,
looping: bool,
nextScene: ?[]const u8,

pub fn load() Self {
    rl.setTargetFPS(60);
    return .{ 
        .start = rl.getTime(),
        .looping = true,
        .nextScene = "menu",
    };

}

pub fn unload(self: *Self) void {
    _ = self;
}

pub fn loop(self: *Self) void {
    rl.beginDrawing();
    defer rl.endDrawing();
    defer rl.clearBackground(rl.Color.black);

    rl.drawText(
        "Made by Marius",
        5,
        5,
        Common.MenuTitleFontSize,
        Colors.WhiteGray,
    );

    if (self.start + 5.0 < rl.getTime()) {
        self.looping = false;
    }
}



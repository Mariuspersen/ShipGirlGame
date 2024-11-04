const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const Config = @import("config.zig");
const Memory = @import("memory.zig");

const Self = @This();

position: rl.Vector2,
size: rl.Vector2,
enabled: bool = false,
fontSize: i32,
text: [100:0]u8,

pub fn init() Self {
    return .{
        .position = rl.Vector2.init(
            Config.get(f32, "ConsolePosX"),
            Config.get(f32, "ConsolePosY"),
        ),
        .size = rl.Vector2.init(
            Config.get(f32, "ConsoleSizeX"),
            Config.get(f32, "ConsoleSizeY"),
        ),
        .text = std.mem.zeroes([100:0]u8),
        .fontSize = Config.get(i32, "ConsoleTextSize"),
    };
}

pub fn draw(self: *Self) void {
    if (!self.enabled) return;
    const r = rl.Rectangle.init(self.position.x, self.position.y, self.size.x, self.size.y);
    const result = rg.guiTextBox(r, &self.text, self.fontSize, true);
    if (result != 0) {
        std.debug.print("Result: {d} -> {s}\n", .{ result, self.text });
    }
}

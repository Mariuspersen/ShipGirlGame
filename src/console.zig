const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const Config = @import("config.zig");
const Memory = @import("memory.zig");
const Input = @import("input.zig");


const Self = @This();

position: rl.Vector2,
size: rl.Vector2,
enabled: bool = false,
fontSize: i32,
text: [100:0]u8,

pub fn init() Self {
    const wHeight: f32 = @floatFromInt(Config.get(i32, "WindowHeight"));
    return .{
        .position = rl.Vector2.init(
            Config.get(f32, "ConsolePosX"),
            wHeight - Config.get(f32, "ConsolePosY") * 2,
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
        self.parseText() catch |err| {
            _ = std.fmt.bufPrintZ(&self.text, "ERROR: {s}", .{@errorName(err)}) catch {};
        };
    }
}

pub fn parseText(self: *Self) !void {
    defer self.text = std.mem.zeroes([100:0]u8);
    var it = std.mem.splitAny(u8, &self.text, " ");

    const cmd = it.first();

    if (std.mem.eql(u8, "bind", cmd)) {
        const keyFunction = it.next() orelse return error.TooFewArguments;
        const keyboardKey = it.next() orelse return error.TooFewArguments;
        const macro = Input.Macro{
            .func = try Input.KeyFunction.fromText(keyFunction),
            .key = try Input.keyboardKeyFromText(keyboardKey),
        };
        _ = try std.fmt.bufPrintZ(&self.text, "{any}", .{macro});
    }

    return error.NotACommand;
}

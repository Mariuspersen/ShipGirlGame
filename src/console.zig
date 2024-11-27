const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const Config = @import("config.zig");
const Common = @import("common.zig");

const Memory = @import("memory.zig");
const Input = @import("input.zig");
const Scenes = @import("sceneManager.zig");


const Self = @This();

const LENGTH = 400;

position: rl.Vector2,
size: rl.Vector2,
enabled: bool = false,
fontSize: i32,
text: [LENGTH:0]u8,

pub fn init() !Self {
    const convarHeight = try Config.get(i32, "WindowHeight");
    const wHeight: f32 = @floatFromInt(convarHeight);
    return .{
        .position = rl.Vector2.init(
            try Config.get(f32, "ConsolePosX"),
            wHeight - try Config.get(f32, "ConsolePosY") * 2,
        ),
        .size = rl.Vector2.init(
            try Config.get(f32, "ConsoleSizeX"),
            try Config.get(f32, "ConsoleSizeY"),
        ),
        .text = std.mem.zeroes([LENGTH:0]u8),
        .fontSize = try Config.get(i32, "ConsoleTextSize"),
    };
}

pub fn draw(self: *Self) void {
    if (!self.enabled) return;
    const r = rl.Rectangle.init(self.position.x, self.position.y, self.size.x, self.size.y);
    const result = rg.guiTextBox(r, &self.text, LENGTH, true);
    if (result != 0) {
        for (&self.text) |*c| if (c.* == 0) {
            c.* = ' ';
            break;
        };
        self.parseText() catch |err| {
            _ = std.fmt.bufPrintZ(&self.text, "ERROR: {s}", .{@errorName(err)}) catch {};
        };
    }
}

pub fn parseText(self: *Self) !void {
    defer self.text = std.mem.zeroes([LENGTH:0]u8);
    var it = std.mem.splitAny(u8, &self.text, " \n\r");

    const cmd = it.next() orelse return error.NoCommandEntered;

    if (std.mem.eql(u8, "bind", cmd)) {
        const bindName = it.next() orelse return error.TooFewArguments;
        const keyFunction = it.next() orelse return error.TooFewArguments;
        const keyboardKey = it.next() orelse return error.TooFewArguments;
        try Input.setKeyBind(
            bindName,
            try Input.keyboardKeyFromText(keyboardKey),
            try Input.KeyFunction.fromText(keyFunction),
        );
        return;
    }

    if (std.mem.eql(u8, "scene", cmd)) {
        const arg = it.next() orelse return error.TooFewArguments;
        const scene = try Scenes.SceneIdfromText(arg);
        try Scenes.changeScene(scene);
        return;
    }

    if (std.mem.eql(u8, "decorations", cmd)) {
        const arg = it.next() orelse return error.TooFewArguments;
        if (arg[0] == '1') {
            Common.windowConfigFlags.window_undecorated = false;
        }
        else if (arg[0] == '0') {
            Common.windowConfigFlags.window_undecorated = true;
        }
        else return error.NotAValidNumber;

        rl.setWindowState(Common.windowConfigFlags);

        return;
    }

    if (std.mem.eql(u8, "quit", cmd)) {
        try Scenes.changeScene(.Quit);
        return;
    }

    return error.NotACommand;
}

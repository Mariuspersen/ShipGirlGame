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
buffer: std.ArrayList(u8),

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
        .buffer = std.ArrayList(u8).init(Memory.Allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.buffer.deinit();
}

pub fn draw(self: *Self) void {
    if (!self.enabled) return;
    var it = std.mem.splitAny(u8, self.buffer.items, "\n\r");
    var offset: i32 = 1;
    while (it.next()) |line| {
        offset += self.fontSize;
        var lineSentinel: [LENGTH:0]u8 = std.mem.zeroes([LENGTH:0]u8);
        _ = std.fmt.bufPrintZ(&lineSentinel, "{s}", .{line}) catch {};
        const xpos: i32 = @intFromFloat(self.position.x);
        const ypos: i32 = @intFromFloat(self.position.y);
        rl.drawText(
            &lineSentinel,
            xpos,
            ypos - offset,
            self.fontSize,
            rl.Color.white,
        );
    }
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
        } else if (arg[0] == '0') {
            Common.windowConfigFlags.window_undecorated = true;
        } else return error.NotAValidNumber;

        rl.setWindowState(Common.windowConfigFlags);

        return;
    }

    if (std.mem.eql(u8, "config", cmd)) {
        const operation = it.next() orelse return error.TooFewArguments;
        const name = it.next() orelse return error.TooFewArguments;

        if (std.mem.eql(u8, "add", operation)) {
            const value = it.next() orelse return error.TooFewArguments;

            const truth = std.mem.eql(u8, "true", value);
            if (truth or std.mem.eql(u8, "false", value)) {
                try Config.add(name, truth);
                return;
            }

            if (std.fmt.parseInt(i32, value, 10)) |number| {
                try Config.add(name, number);
                return;
            } else |_| {}

            if (std.fmt.parseFloat(f32, value)) |number| {
                try Config.add(name, number);
                return;
            } else |_| {}

            try Config.add(name, value);
        } else if (std.mem.eql(u8, "get", operation)) {
            const typeText = it.next() orelse return error.TooFewArguments;
            const info = @typeInfo(Config.conVar);
            inline for (info.Union.fields) |field| {
                if (std.mem.eql(u8, typeText, field.name)) {
                    const T = if (field.type == u8) bool else field.type;
                    const convar = try Config.get(T, name);
                    try self.buffer.writer().print(
                        if (T == [:0]const u8) "{s}: {s}\n" else "{s}: {any}\n",
                        .{ name, convar },
                    );
                    return;
                }
            }
        }

        return;
    }

    if (std.mem.eql(u8, "quit", cmd)) {
        try Scenes.changeScene(.Quit);
        return;
    }

    return error.NotACommand;
}

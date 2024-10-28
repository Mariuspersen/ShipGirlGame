const rl = @import("raylib");
const std = @import("std");

const Config = @import("config.zig");
const Common = @import("common.zig");

pub var currentKey: rl.KeyboardKey = .key_null;
pub var modifierKey: rl.KeyboardKey = .key_null;

const KeyAction = union(enum) {
    fullscreen: @TypeOf(Common.toggleFullscreen),
};

const KeyFunction = enum {
    isKeyDown,
    isKeyPressed,
    isKeyPressedRepeat,
    isKeyReleased,
    isKeyUp,
};

const Macro = struct {
    key: rl.KeyboardKey,
    func: KeyFunction,
};

pub fn read() void {
    for (0..2) |_| {
        switch (rl.getKeyPressed()) {
            .key_left_control,
            .key_right_control,
            .key_left_super,
            .key_right_super,
            .key_left_alt,
            .key_right_alt,
            => |k| modifierKey = k,
            .key_null => {},
            else => |k| currentKey = k,
        }
    }
}

pub fn clear() void {
    if (rl.isKeyUp(currentKey)) currentKey = .key_null;
    if (rl.isKeyUp(modifierKey)) modifierKey = .key_null;
}

const bind_modifier: []const u8 = "k_";

pub fn setKeyBind(comptime name: []const u8, key: rl.KeyboardKey, func: KeyFunction) !void {
    const funcInt: u16 = @intFromEnum(func);
    const keyInt: u16 = @intCast(@intFromEnum(key));
    const compact: u32 = (funcInt << 15) | keyInt;
    const fname = bind_modifier ++ name;
    try Config.vars.add(fname, @as(i32, @bitCast(compact)));
}

pub fn getKeyBind(comptime name: []const u8) Macro {
    const fname = bind_modifier ++ name;
    const compact: u32 = @bitCast(Config.vars.get(i32, fname));
    const funcInt: u16 = @intCast(compact >> 15);
    const keyInt: u16 = @intCast(compact & 0x7FFF);
    return .{
        .func = @enumFromInt(funcInt),
        .key = @enumFromInt(keyInt),
    };
}

const rl = @import("raylib");
const std = @import("std");

const Config = @import("config.zig");
const Memory = @import("memory.zig");
const Common = @import("common.zig");

pub var currentKey: rl.KeyboardKey = .key_null;
pub var modifierKey: rl.KeyboardKey = .key_null;

const KeyAction = union(enum) {
    fullscreen: @TypeOf(Common.toggleFullscreen),
};

pub const KeyFunction = enum {
    isKeyDown,
    isKeyPressed,
    isKeyPressedRepeat,
    isKeyReleased,
    isKeyUp,

    pub fn fromText(text: []const u8) !KeyFunction {
        inline for (@typeInfo(KeyFunction).Enum.fields) |field| {
            if (std.mem.eql(u8, text, field.name)) {
                return @enumFromInt(field.value);
            }
        }
        return error.InvalidKeyFunctionEnum;
    }
};

pub fn keyboardKeyFromText(text: []const u8) !rl.KeyboardKey {
    inline for (@typeInfo(rl.KeyboardKey).Enum.fields) |field| {
            if (std.mem.eql(u8, text, field.name)) {
                return @enumFromInt(field.value);
            }
    }
    return error.InvalidKeyBoardKeyEnum;
}

pub const Macro = struct {
    key: rl.KeyboardKey,
    func: KeyFunction,

    pub fn handleMacro(self: *Macro) bool {
        return switch (self.func) {
            .isKeyUp => rl.isKeyUp(self.key),
            .isKeyDown => rl.isKeyDown(self.key),
            .isKeyPressed => rl.isKeyPressed(self.key),
            .isKeyReleased => rl.isKeyReleased(self.key),
            .isKeyPressedRepeat => rl.isKeyPressedRepeat(self.key),
        };
    }
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

const bind_modifier = "k_";

pub fn setKeyBind(name: []const u8, key: rl.KeyboardKey, func: KeyFunction) !void {
    const funcInt: u16 = @intFromEnum(func);
    const keyInt: u16 = @intCast(@intFromEnum(key));
    const compact: u32 = (funcInt << 15) | keyInt;
    const fname = try std.mem.concat(
        Memory.Allocator,
        u8,
        &.{ bind_modifier, name },
    );
    defer Memory.Allocator.free(fname);
    try Config.add(fname, @as(i32, @bitCast(compact)));
}

pub fn getKeyBind(name: []const u8) !Macro {
    const fname = try std.mem.concat(
        Memory.Allocator,
        u8,
        &.{ bind_modifier, name },
    );
    defer Memory.Allocator.free(fname);
    const compact: u32 = @bitCast(Config.get(i32, fname));
    const funcInt: u16 = @intCast(compact >> 15);
    const keyInt: u16 = @intCast(compact & 0x7FFF);
    return .{
        .func = @enumFromInt(funcInt),
        .key = @enumFromInt(keyInt),
    };
}

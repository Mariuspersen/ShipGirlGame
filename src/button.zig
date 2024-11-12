const rl = @import("raylib");
const std = @import("std");
const Common = @import("common.zig");
const Config = @import("config.zig");
const Self = @This();

location: union(enum) {
    real: rl.Vector2,
    scale: rl.Vector2,
},
size: union(enum) {
    real: rl.Vector2,
    scale: rl.Vector2,
},
icon: ?*rl.Texture2D,
text: ?[:0]const u8,
colorHover: rl.Color = rl.Color.gray,
color: rl.Color = rl.Color.dark_gray,

pub fn init(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    scaledLoc: bool,
    scaledSize: bool,
    icon: ?*rl.Texture2D,
    text: ?[:0]const u8,
) Self {
    return .{
        .location = if (scaledLoc) .{ .scale = rl.Vector2.init(x, y) } else .{ .real = rl.Vector2.init(x, y) },
        .size = if (scaledSize) .{ .scale = rl.Vector2.init(width, height) } else .{ .real = rl.Vector2.init(width, height) },
        .icon = icon,
        .text = text,
    };
}

pub fn draw(self: *const Self) !void {
    const convarWidth = try Config.get(i32, "WindowWidth");
    const convarHeight = try Config.get(i32, "WindowHeight");
    const fWidth: f32 = @floatFromInt(convarWidth);
    const fHeight: f32 = @floatFromInt(convarHeight);
    const trueLoc = switch (self.location) {
        .scale => |s| rl.Vector2.init(s.x * fWidth, s.y * fHeight),
        .real => |r| r,
    };
    const trueSize = switch (self.size) {
        .scale => |s| rl.Vector2.init(s.x * fWidth, s.y * fHeight),
        .real => |r| r,
    };
    rl.drawRectangle(
        @intFromFloat(trueLoc.x),
        @intFromFloat(trueLoc.y),
        @intFromFloat(trueSize.x),
        @intFromFloat(trueSize.y),
        if (try self.hover()) self.colorHover else self.color,
    );

    if (self.icon) |icon| {
        icon.draw(
            @intFromFloat(trueLoc.x + ((trueSize.x - @as(f32, @floatFromInt(icon.width)))) / 2),
            @intFromFloat(trueLoc.y + ((trueSize.y - @as(f32, @floatFromInt(icon.height)))) / 2),
            rl.Color.white,
        );
    }

    const fontSize = try Config.get(i32, "NormalFontSize");

    if (self.text) |text| {
        const width = rl.measureText(text, fontSize);
        rl.drawText(
            text,
            @intFromFloat(trueLoc.x + ((trueSize.x - @as(f32, @floatFromInt(width)))) / 2),
            @intFromFloat(trueLoc.y + ((trueSize.y - @as(f32, @floatFromInt(fontSize)))) / 2),
            fontSize,
            rl.Color.white,
        );
    }
}

fn getLocVec(self: *const Self) rl.Vector2 {
    return switch (self.location) {
        .scale => |s| s,
        .real => |r| r,
    };
}

fn getSizeVec(self: *const Self) rl.Vector2 {
    return switch (self.size) {
        .scale => |s| s,
        .real => |r| r,
    };
}

pub fn pressed(self: *const Self) !bool {
    return rl.isMouseButtonReleased(.mouse_button_left) and try self.hover();
}

pub fn down(self: *const Self) bool {
    _ = self;
    return rl.isMouseButtonDown(.mouse_button_left);
}

pub fn hover(self: *const Self) !bool {
    const mousePosition = rl.getMousePosition();
    const convarWidth = try Config.get(i32, "WindowWidth");
    const convarHeight = try Config.get(i32, "WindowHeight");
    const fWidth: f32 = @floatFromInt(convarWidth);
    const fHeight: f32 = @floatFromInt(convarHeight);
    const loc = switch (self.location) {
        .scale => |s| rl.Vector2.init(s.x * fWidth, s.y * fHeight),
        .real => |r| r,
    };
    const size = switch (self.size) {
        .scale => |s| rl.Vector2.init(s.x * fWidth, s.y * fHeight),
        .real => |r| r,
    };
    return mousePosition.x > loc.x and mousePosition.y > loc.y and mousePosition.x < loc.x + size.x and mousePosition.y < loc.y + size.y;
}

pub fn modifyFactor(self: *Self, x: ?f32, y: ?f32, width: ?f32, height: ?f32) void {
    if (x) |xx| {
        switch (self.location) {
            .scale => |*s| s.x = xx,
            else => {},
        }
    }
    if (y) |yy| {
        switch (self.location) {
            .scale => |*s| s.y = yy,
            else => {},
        }
    }
    if (width) |wwidth| {
        switch (self.size) {
            .scale => |*s| s.x = wwidth,
            else => {},
        }
    }
    if (height) |hheight| {
        switch (self.size) {
            .scale => |*s| s.y = hheight,
            else => {},
        }
    }
}

const rl = @import("raylib");
const std = @import("std");
const Common = @import("common.zig");
const Self = @This();

location: union(enum) {
    real: rl.Vector2,
    scale: rl.Vector2,
},
size: union(enum) {
    real: rl.Vector2,
    scale: rl.Vector2,
},
icon: *rl.Texture2D,
colorHover: rl.Color = rl.Color.gray,
color: rl.Color = rl.Color.dark_gray,

pub fn init(
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    scaledLoc: bool,
    scaledSize: bool,
    icon: *rl.Texture2D,
) Self {
    return .{
        .location = if (scaledLoc) .{ .scale = rl.Vector2.init(x, y) } else .{ .real = rl.Vector2.init(x, y) },
        .size = if (scaledSize) .{ .scale = rl.Vector2.init(width, height) } else .{ .real = rl.Vector2.init(width, height) },
        .icon = icon,
    };
}

pub fn draw(self: *const Self) void {
    const fWidth: f32 = @floatFromInt(Common.Width);
    const fHeight: f32 = @floatFromInt(Common.Height);
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
        if (self.hover()) self.colorHover else self.color,
    );
    self.icon.draw(
        @intFromFloat(trueLoc.x + ((trueSize.x - @as(f32, @floatFromInt(self.icon.width)))) / 2),
        @intFromFloat(trueLoc.y + ((trueSize.y - @as(f32, @floatFromInt(self.icon.height)))) / 2),
        rl.Color.white,
    );
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

pub fn pressed(self: *const Self) bool {
    return rl.isMouseButtonReleased(.mouse_button_left) and self.hover();
}

inline fn hover(self: *const Self) bool {
    const mousePosition = rl.getMousePosition();
    const fWidth: f32 = @floatFromInt(Common.Width);
    const fHeight: f32 = @floatFromInt(Common.Height);
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
    if(x) |xx| {
        switch (self.location) {
            .scale => |*s| s.x = xx,
            else => {},
        }
    }
    if(y) |yy| {
        switch (self.location) {
            .scale => |*s| s.y = yy,
            else => {},
        }
    }
    if(width) |wwidth| {
        switch (self.location) {
            .scale => |*s| s.x = wwidth,
            else => {},
        }
    }
    if(height) |hheight| {
        switch (self.location) {
            .scale => |*s| s.x = hheight,
            else => {},
        }
    }
}
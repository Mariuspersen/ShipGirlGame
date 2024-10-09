const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");
const math = std.math;

const Scene = @import("sceneList.zig").sceneList;

pub var Width: i32 = 1920;
pub var Height: i32 = 1080;
pub var Framerate: i32 = 60;
pub var Fullscreen: bool = false;
pub const Title = "Project SHIP";
pub const MenuTitleFontSize = 40;
pub const NormalFontSize = 20;
pub const Version = @embedFile("version");
pub const Zero: usize = 0;
pub const StartScene: Scene = switch (builtin.mode) {
    .Debug => Scene.Base,
    else => Scene.Intro,
};

//Change allocator used based on Debug or Release builds
var allocatorType: blk: {
    switch (builtin.mode) {
        .Debug => break :blk std.heap.GeneralPurposeAllocator(.{}),
        else => break :blk std.heap.ArenaAllocator,
    }
} = blk: {
    switch (builtin.mode) {
        .Debug => break :blk std.heap.GeneralPurposeAllocator(.{}){},
        else => break :blk std.heap.ArenaAllocator.init(std.heap.page_allocator),
    }
};

pub var allocator: std.mem.Allocator = undefined;

pub fn initAllocator() void {
    allocator = allocatorType.allocator();
}

pub fn deinitAllocator() void {
    switch (builtin.mode) {
        .Debug => _ = {
            _ = allocatorType.detectLeaks();
            _ = allocatorType.deinit();
        },
        else => {
            allocatorType.deinit();
        },
    }
}

pub fn initVariables() void {
    switch (builtin.mode) {
        .Debug => {
            rl.setWindowSize(Width, Height);
        },
        else => {
            const monitor = rl.getCurrentMonitor();
            Height = rl.getMonitorHeight(monitor);
            Width = rl.getMonitorWidth(monitor);
            Framerate = rl.getMonitorRefreshRate(monitor);
            Fullscreen = true;
            rl.setWindowSize(Width, Height);
        },
    }
}

pub fn scale(n: anytype, a: anytype, b: anytype, x: anytype, z: anytype) @TypeOf(n, a, b, x, z) {
    return (n - a) * (z - x) / (b - a) + x;
}

pub fn fade(t: anytype, fade_in: anytype, sustain: anytype, fade_out: anytype) @TypeOf(t, fade_in, sustain, fade_out) {
    const total = fade_in + sustain + fade_out;
    const new_t = math.clamp(t, 0.0, total);
    const new_fade_in = @min(1.0, new_t / fade_in);
    const new_fade_out = @min(1.0, (total - new_t) / fade_out);

    return @min(new_fade_in, new_fade_out);
}

var debugPos: i32 = 0;
pub inline fn drawDebugInfo(camera: *rl.Camera3D) !void {
    drawVersionNumber();
    try drawFPS();
    try drawPosition(camera);
    debugPos = 0;
}

pub inline fn drawVersionNumber() void {
    rl.drawText(
        "VERSION: " ++ Version,
        0,
        debugPos * NormalFontSize,
        NormalFontSize,
        rl.Color.white,
    );
    debugPos += 1;
}

pub inline fn drawFPS() !void {
    var buf: [10]u8 = undefined;
    const fps = rl.getFPS();
    const string = try std.fmt.bufPrintZ(&buf, "FPS: {d}", .{fps});
    rl.drawText(
        string,
        0,
        debugPos * NormalFontSize,
        NormalFontSize,
        rl.Color.white,
    );
    debugPos += 1;
}

pub inline fn drawPosition(camera: *rl.Camera3D) !void {
    var buffer: [64]u8 = undefined;
    const string = try std.fmt.bufPrintZ(
        &buffer,
        "PLAYER POS: X: {d}\tY: {d}\tZ: {d}",
        .{
            @trunc(camera.position.x),
            @trunc(camera.position.y),
            @trunc(camera.position.z),
        },
    );
    rl.drawText(
        string,
        0,
        debugPos * NormalFontSize,
        20,
        rl.Color.white,
    );
    debugPos += 1;
}

pub inline fn initDrawLoadingMessage(name: [:0]const u8, count: *const usize) !void {
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(rl.Color.black);

    var buffer: [64]u8 = undefined;
    const string = try std.fmt.bufPrintZ(
        &buffer,
        "[ {d} ] Loading {s}",
        .{
            count.*,
            name,
        },
    );
    rl.drawText(
        string,
        0,
        0 * NormalFontSize,
        20,
        rl.Color.white,
    );
}

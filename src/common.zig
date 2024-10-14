const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");
const rg = @import("raygui");

const math = std.math;

const Scene = @import("sceneList.zig").sceneList;
const Assets = @import("assetManager.zig");

pub var Width: i32 = 1280;
pub var Height: i32 = 720;
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

pub const windowConfigFlags = rl.ConfigFlags{
    .window_resizable = true,
    .window_undecorated = true,
    .window_always_run = true,
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
            rl.toggleFullscreen();
            rl.setWindowSize(Width, Height);
        },
    }
    rl.setWindowState(windowConfigFlags);
    rl.setLoadFileDataCallback(Assets.loadDataCallback);
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
var debugBuffer: [64]u8 = undefined;
pub inline fn drawDebugInfo(camera: *rl.Camera3D) !void {
    drawVersionNumber();
    try drawPosition(camera);
    try drawFPS();
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
    const fps = rl.getFPS();
    const frametime = rl.getFrameTime();
    const string = try std.fmt.bufPrintZ(&debugBuffer, "FPS: {d} Frametime: {d:>4}", .{fps,frametime});
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
    
    const string = try std.fmt.bufPrintZ(
        &debugBuffer,
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

    const string = try std.fmt.bufPrintZ(
        &debugBuffer,
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

pub inline fn drawCloseBtn() bool {
    const size = 0.02;
    const scaled = @as(f32, @floatFromInt(Width)) * size;
    const close_btn = rl.Rectangle.init( @as(f32, @floatFromInt(Width)) - scaled - 5, 5, scaled, scaled);
    const pressed = rg.guiButton(close_btn, "X");
    return pressed == 1;
}

pub inline fn toggleFullscreen() void {
    rl.toggleBorderlessWindowed();
    Width = rl.getScreenWidth();
    Height = rl.getScreenHeight();
}

pub inline fn checkWindowResized() void {
    if (rl.isWindowResized()) {
        Width = rl.getScreenWidth();
        Height = rl.getScreenHeight();
    }
}
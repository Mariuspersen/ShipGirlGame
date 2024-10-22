//Imports
const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");
const rg = @import("raygui");
const math = std.math;
const Scene = @import("sceneList.zig").sceneList;
const Assets = @import("assetManager.zig");
const Button = @import("button.zig");
const Memory = @import("memory.zig");
//Public Variables
pub var Width: i32 = 1280;
pub var Height: i32 = 720;
pub var Framerate: i32 = 60;
pub var Fullscreen: bool = false;
pub var UiCloseText: rl.Texture2D = undefined;
pub var UIMaximizeText: rl.Texture2D = undefined;
pub var UIMinimizeText: rl.Texture2D = undefined;
pub var UICloseBtn: Button = undefined;
pub var UIMaximizeBtn: Button = undefined;
pub var UIMinimizeBtn: Button = undefined;

//Public Constants
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
            toggleFullscreen();
            rl.setWindowSize(Width, Height);
        },
    }
    initUiButtons();
    rl.setWindowState(windowConfigFlags);
    rl.setLoadFileDataCallback(Assets.loadDataCallback);
}

pub fn deinitVariables() void {
    UiCloseText.unload();
    UIMaximizeText.unload();
    UIMinimizeText.unload();
}

fn initUiButtons() void {
    var close = Assets.barIcons.getImage();
    var max = Assets.barIcons.getImage();
    var min = Assets.barIcons.getImage();
    defer close.unload();
    defer max.unload();
    defer min.unload();
    const tileWidth: f32 = @as(f32, @floatFromInt(min.width)) / 3.0;
    min.crop(rl.Rectangle.init(0, 0, tileWidth, @floatFromInt(min.height)));
    max.crop(rl.Rectangle.init(tileWidth, 0, tileWidth, @floatFromInt(min.height)));
    close.crop(rl.Rectangle.init(tileWidth * 2, 0, tileWidth, @floatFromInt(min.height)));
    UiCloseText = rl.loadTextureFromImage(close);
    UIMaximizeText = rl.loadTextureFromImage(max);
    UIMinimizeText = rl.loadTextureFromImage(min);
    UICloseBtn = Button.init(
        (@as(f32, @floatFromInt(Width)) - 46) / @as(f32, @floatFromInt(Width)),
        0.0,
        46,
        46,
        true,
        false,
        &UiCloseText,
    );
    UICloseBtn.colorHover = rl.Color.red;
    UIMaximizeBtn = Button.init(
        (@as(f32, @floatFromInt(Width)) - (46*2)) / @as(f32, @floatFromInt(Width)),
        0.0,
        46,
        46,
        true,
        false,
        &UIMaximizeText,
    );
    UIMinimizeBtn = Button.init(
        (@as(f32, @floatFromInt(Width)) - (46*3)) / @as(f32, @floatFromInt(Width)),
        0.0,
        46,
        46,
        true,
        false,
        &UIMinimizeText,
    );
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
    const string = try std.fmt.bufPrintZ(&debugBuffer, "FPS: {d} Frametime: {d:>4}", .{ fps, frametime });
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
    UICloseBtn.draw();
    UIMaximizeBtn.draw();
    UIMinimizeBtn.draw();
    if (UIMinimizeBtn.pressed()) {
        if (rl.isWindowMinimized()) {
            rl.restoreWindow();
        } else {
            rl.minimizeWindow();
        }
    }
    if (UIMaximizeBtn.pressed()) {
        if (rl.isWindowMaximized()) {
            rl.restoreWindow();
        } else {
            rl.maximizeWindow();
        }
        checkWindowResized();
    }
    return UICloseBtn.pressed();
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
        UICloseBtn.modifyFactor(
            (@as(f32, @floatFromInt(Width)) - UICloseBtn.size.real.x) / @as(f32, @floatFromInt(Width)),
            null,
            null,
            null,
        );
        UIMaximizeBtn.modifyFactor(
            (@as(f32, @floatFromInt(Width)) - UIMaximizeBtn.size.real.x*2) / @as(f32, @floatFromInt(Width)),
            null,
            null,
            null,
        );
        UIMinimizeBtn.modifyFactor(
            (@as(f32, @floatFromInt(Width)) - UIMaximizeBtn.size.real.x*3) / @as(f32, @floatFromInt(Width)),
            null,
            null,
            null,
        );
    }
}

pub fn drawSlider(value: *f32, x: f32, y: f32, width: f32, height: f32,text: [*:0]const u8) void {
    const rect = rl.Rectangle.init(x + 20.0,y,width,height);
    const val = std.fmt.allocPrintZ(Memory.Allocator, "{d}", .{value.*}) catch return;
    defer Memory.Allocator.free(val);
    _ = rg.guiSlider(rect, text, val, value, 0.0, 1.0);

}

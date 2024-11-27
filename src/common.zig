//Imports
const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");
const rg = @import("raygui");
const math = std.math;
const SceneManager = @import("sceneManager.zig");
const Assets = @import("assetManager.zig");
const Button = @import("button.zig");
const Memory = @import("memory.zig");
const Config = @import("config.zig");

const Scene = SceneManager.Scene;

//Public Variables
pub var Fullscreen: bool = false;
pub var UiCloseText: rl.Texture2D = undefined;
pub var UIMaximizeText: rl.Texture2D = undefined;
pub var UIMinimizeText: rl.Texture2D = undefined;
pub var UICloseBtn: Button = undefined;
pub var UIMaximizeBtn: Button = undefined;
pub var UIMinimizeBtn: Button = undefined;
pub var UITitleBar: Button = undefined;

//Public Constants
pub const Version = @embedFile("version");
pub const Zero: usize = 0;

pub var windowConfigFlags = rl.ConfigFlags{
    .window_resizable = true,
    .window_undecorated = true,
    .window_always_run = true,
};

pub fn init() !void {
    rl.initWindow(
        try Config.get(i32, "WindowWidth"),
        try Config.get(i32, "WindowHeight"),
        try Config.get([:0]const u8, "WindowTitle"),
    );

    switch (builtin.mode) {
        .Debug => {},
        else => try toggleFullscreen(),
    }

    try Config.add("TitleBarOffset", @as(i32, 0));

    try initUiButtons();
    rl.setWindowState(windowConfigFlags);
    rl.setExitKey(.key_null);
    rl.setLoadFileDataCallback(Assets.loadDataCallback);
    rl.setTargetFPS(try Config.get(i32, "Framerate"));
}

pub fn deinit() void {
    UiCloseText.unload();
    UIMaximizeText.unload();
    UIMinimizeText.unload();
    rl.closeWindow();
}

fn initUiButtons() !void {
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

    const convarWidth = try Config.get(i32, "WindowWidth");
    const convarHeight = try Config.get(i32, "WindowHeight");
    const width: f32 = @floatFromInt(convarWidth);
    const height: f32 = @floatFromInt(convarHeight);

    UICloseBtn = Button.init(
        (width - 46) / width,
        0.0,
        46,
        46,
        true,
        false,
        &UiCloseText,
        null,
    );
    UICloseBtn.colorHover = rl.Color.red;
    UIMaximizeBtn = Button.init(
        (width - (46 * 2)) / width,
        0.0,
        46,
        46,
        true,
        false,
        &UIMaximizeText,
        null,
    );
    UIMinimizeBtn = Button.init(
        (width - (46 * 3)) / width,
        0.0,
        46,
        46,
        true,
        false,
        &UIMinimizeText,
        null,
    );
    UITitleBar = Button.init(
        0.0,
        0.0,
        (width - (46 * 3)) / width,
        (height - (height - 46)) / height,
        false,
        true,
        null,
        try Config.get([:0]const u8, "WindowTitle"),
    );
    UITitleBar.colorHover = rl.Color.dark_gray;
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
pub fn drawDebugInfo(camera: *rl.Camera3D) !void {
    const normalFontSize = try Config.get(i32, "NormalFontSize");
    const titleBarOffset = try Config.get(i32, "TitleBarOffset");
    drawVersionNumber(normalFontSize, titleBarOffset);
    try drawPosition(camera, normalFontSize, titleBarOffset);
    try drawFPS(normalFontSize, titleBarOffset);
    debugPos = 0;
}

pub fn drawVersionNumber(normalFontSize: i32, titleBarOffset: i32) void {
    rl.drawText(
        "VERSION: " ++ Version,
        0,
        (debugPos * normalFontSize) + titleBarOffset,
        normalFontSize,
        rl.Color.white,
    );
    debugPos += 1;
}

pub fn drawFPS(normalFontSize: i32, titleBarOffset: i32) !void {
    const fps = rl.getFPS();
    const frametime = rl.getFrameTime();
    const string = try std.fmt.bufPrintZ(&debugBuffer, "FPS: {d} Frametime: {d:>4}", .{ fps, frametime });
    rl.drawText(
        string,
        0,
        (debugPos * normalFontSize) + titleBarOffset,
        normalFontSize,
        rl.Color.white,
    );
    debugPos += 1;
}

pub fn drawPosition(camera: *rl.Camera3D, normalFontSize: i32, titleBarOffset: i32) !void {
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
        (debugPos * normalFontSize) + titleBarOffset,
        normalFontSize,
        rl.Color.white,
    );
    debugPos += 1;
}

pub fn initDrawLoadingMessage(name: [:0]const u8, count: usize, normalFontSize: i32, titleBarOffset: i32) !void {
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(rl.Color.black);

    const string = try std.fmt.bufPrintZ(
        &debugBuffer,
        "[ {d} ] Loading {s}",
        .{
            count,
            name,
        },
    );
    rl.drawText(
        string,
        0,
        (0 * normalFontSize) + titleBarOffset,
        20,
        rl.Color.white,
    );
}

var offset: ?rl.Vector2 = null;

pub fn drawTitleBar() !bool {
    if (rl.getMousePosition().y > 50 and rl.isWindowMaximized()) {
        try Config.add("TitleBarOffset", @as(i32, 0));
        return false;
    } else {
        try Config.add("TitleBarOffset", @as(i32, 46));
    }
    try UICloseBtn.draw();
    try UIMaximizeBtn.draw();
    try UIMinimizeBtn.draw();
    try UITitleBar.draw();
    if (try UIMinimizeBtn.pressed()) {
        if (rl.isWindowMinimized()) {
            rl.restoreWindow();
        } else {
            rl.minimizeWindow();
        }
    }
    if (try UIMaximizeBtn.pressed()) {
        if (rl.isWindowMaximized()) {
            rl.restoreWindow();
        } else {
            rl.maximizeWindow();
        }
        try checkWindowResized();
    }
    if (UITitleBar.down() and try UITitleBar.hover()) {
        if (offset) |vOffset| {
            const oldWPos = rl.getWindowPosition();
            const rMousePos = rl.getMousePosition();
            const gMousePos = rMousePos.add(oldWPos);
            const wPos = gMousePos.subtract(vOffset);
            rl.setWindowPosition(@intFromFloat(wPos.x), @intFromFloat(wPos.y));
        } else {
            offset = rl.getMousePosition();
        }
    } else {
        offset = null;
    }
    return UICloseBtn.pressed();
}

pub fn toggleFullscreen() !void {
    rl.toggleBorderlessWindowed();
    try checkWindowResized();
}

pub fn checkWindowResized() !void {
    if (rl.isWindowResized()) {
        try Config.add("WindowWidth", rl.getScreenWidth());
        try Config.add("WindowHeight", rl.getScreenHeight());
        const convarWidth = try Config.get(i32, "WindowWidth");
        const convarHeight = try Config.get(i32, "WindowHeight");
        const fWidth: f32 = @floatFromInt(convarWidth);
        const fHeight: f32 = @floatFromInt(convarHeight);
        UICloseBtn.modifyFactor(
            (fWidth - UICloseBtn.size.real.x) / fWidth,
            null,
            null,
            null,
        );
        UIMaximizeBtn.modifyFactor(
            (fWidth - (UIMaximizeBtn.size.real.x * 2)) / fWidth,
            null,
            null,
            null,
        );
        UIMinimizeBtn.modifyFactor(
            (fWidth - (UIMinimizeBtn.size.real.x * 3)) / fWidth,
            null,
            null,
            null,
        );
        UITitleBar.modifyFactor(
            null,
            null,
            (fWidth - (46 * 3)) / fWidth,
            (fHeight - (fHeight - 46)) / fHeight,
        );
    }
}

pub fn drawSlider(value: *f32, x: f32, y: f32, width: f32, height: f32, text: [*:0]const u8) void {
    const rect = rl.Rectangle.init(x + 20.0, y, width, height);
    const val = std.fmt.allocPrintZ(Memory.Allocator, "{d}", .{value.*}) catch return;
    defer Memory.Allocator.free(val);
    _ = rg.guiSlider(rect, text, val, value, 0.0, 1.0);
}

pub fn printError(err: anyerror) void {
    const stderr = std.io.getStdErr().writer();
    stderr.print("ERROR: {s}\n", .{@errorName(err)}) catch return;
}

pub fn alwaysError() !void {
    return error.AlwaysError;
}

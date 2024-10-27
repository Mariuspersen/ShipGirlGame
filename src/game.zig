const std = @import("std");
const rl = @import("raylib");
const Colors = @import("colors.zig");
const Common = @import("common.zig");
const Memory = @import("memory.zig");
const sceneManager = @import("sceneManager.zig");
const Config = @import("config.zig");

const Self = @This();

pub fn Start() !void {

    Memory.initAllocator();
    defer Memory.deinitAllocator();

    try Config.init(Memory.Allocator);
    defer Config.vars.deinit();

    try Common.init();
    defer Common.deinit();

    var scene = try sceneManager.init();
    while (!rl.windowShouldClose() and try scene.loop()) {}
}

const std = @import("std");
const builtin = @import("builtin");

const math = std.math;

pub const Width = 1920;
pub const Height = 1080;
pub const Title = "Project SHIP";
pub const MenuTitleFontSize = 40;

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

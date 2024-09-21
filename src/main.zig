const Game = @import("game.zig");
const Common = @import("common.zig");

pub fn main() !void {
    Common.initAllocator();
    try Game.Start();
    Common.deinitAllocator();
}

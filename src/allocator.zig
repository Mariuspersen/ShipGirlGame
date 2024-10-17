const Common = @import("common.zig");

export fn rlmalloc(size: c_int) callconv(.C) ?*anyopaque {
    const pointer = Common.Allocator.alloc(u8, @intCast(size)) catch return null;
    return @ptrCast(pointer.ptr);
}

//export fn realloc(ptr: ?*anyopaque, size: c_int) callconv(.C) ?*anyopaque {
//    if (ptr) |p| {
//        const pointer = Allocator.realloc(p, @intCast(size)) catch return null;
//        return @ptrCast(pointer.ptr);
//    } 
//    return null;
//}
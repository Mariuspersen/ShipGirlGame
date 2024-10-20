const std = @import("std");
const Date = @import("src/date.zig");

pub fn build(b: *std.Build) !void {
    try writeVersion(b.allocator);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    raylib_artifact.defineCMacro("SUPPORT_FILEFORMAT_JPG", null);

    includeHeader(&raylib_artifact.root_module, "src/memory.h");

    const exe = b.addExecutable(.{
        .name = "projectboat",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn gitHash(allocator: std.mem.Allocator, buffer: *[7]u8) !void {
    //Find current branch(?)
    const head = try std.fs.cwd().openFile(".git/HEAD", .{});
    defer head.close();
    //Read data from HEAD
    const stat = try head.stat();
    const data = try head.readToEndAlloc(allocator, stat.size);
    defer allocator.free(data);

    //Get path to current HEAD's ref
    const index = std.mem.indexOf(u8, data, " ") orelse return error.no_space_in_head;
    const ref_path = try std.fs.path.join(
        allocator,
        &.{ ".git/", data[index + 1 .. data.len - 1] },
    );
    defer allocator.free(ref_path);

    _ = std.mem.replace(
        u8,
        ref_path,
        std.fs.path.sep_str_posix,
        std.fs.path.sep_str,
        ref_path,
    );

    const ref = try std.fs.cwd().openFile(ref_path, .{});
    defer ref.close();

    //Read git hash and copy it to the buffer
    const ref_stat = try ref.stat();
    const ref_data = try ref.readToEndAlloc(allocator, ref_stat.size);
    @memcpy(buffer, ref_data[0..7]);
}

fn writeVersion(allocator: std.mem.Allocator) !void {
    var cwd = std.fs.cwd();
    cwd.deleteFile("src/version") catch {};

    var timestamp = Date.now();
    const formatted = try timestamp.format(allocator);
    defer allocator.free(formatted);

    var buffer: [7]u8 = undefined;
    try gitHash(allocator, &buffer);
    const file = try cwd.createFile("src/version", .{});
    defer file.close();

    try file.writeAll(formatted);
    try file.writeAll("-");
    try file.writeAll(&buffer);
}

fn includeHeader(m: *std.Build.Module, sub_path: []const u8) void {
    const b = m.owner;
    const path = std.fs.cwd().realpathAlloc(b.allocator, sub_path) catch @panic("OOM");
    const string = b.fmt("-include{s}", .{path});

    for (m.link_objects.items) |lobj| {
        switch (lobj) {
            .c_source_file => updateFlags(
                std.Build.Module.CSourceFile,
                b,
                lobj.c_source_file,
                string,
            ),
            .c_source_files => updateFlags(
                std.Build.Module.CSourceFiles,
                b,
                lobj.c_source_files,
                string,
            ),
            else => {},
        }
    }
}

fn updateFlags(T: type, b: *std.Build, c_source_file: *T, path: []u8) void {
    if (T != std.Build.Module.CSourceFile and T != std.Build.Module.CSourceFiles) {
        @compileError("Needs to be CSourceFile or CSourceFiles");
    }
    const new_flags = b.allocator.alloc([]u8, c_source_file.flags.len + 1) catch @panic("OOM");
    for (new_flags[0..c_source_file.flags.len], c_source_file.flags) |*new_flag, old_flag| {
        new_flag.* = b.dupe(old_flag);
    }
    new_flags[new_flags.len - 1] = path;
    c_source_file.flags = new_flags;
}

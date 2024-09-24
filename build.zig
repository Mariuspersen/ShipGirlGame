const std = @import("std");

pub fn build(b: *std.Build) void {
    writeVersion(b.allocator) catch |err| {
        std.debug.print("ERROR: {any}\n", .{err});
    };

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

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
    errdefer @memcpy(buffer, "ERRORS!");
    const head = try std.fs.cwd().openFile(".git/HEAD", .{});
    defer head.close();

    const stat = try head.stat();
    const data = try head.readToEndAlloc(allocator, stat.size);
    defer allocator.free(data);

    const index = std.mem.indexOf(u8, data, " ") orelse return error.no_space_in_head;
    const ref_path = try std.fs.path.join(allocator, &.{".git/",data[index+1..data.len-1]});
    for (ref_path) |*c| if (c.* == '/') { c.* = '\\'; };
    defer allocator.free(ref_path);

    const ref = try std.fs.cwd().openFile(ref_path, .{});
    defer ref.close();

    const ref_stat = try ref.stat();
    const ref_data = try ref.readToEndAlloc(allocator, ref_stat.size);
    @memcpy(buffer, ref_data[0..7]);
}

fn writeVersion(allocator: std.mem.Allocator) !void {
    try std.fs.cwd().deleteFile("./src/version");

    var timestamp = Date.now();
    const formatted = try timestamp.format(allocator);
    defer allocator.free(formatted);

    var buffer: [7]u8 = undefined;
    try gitHash(allocator, &buffer);
    const file = try std.fs.cwd().createFile("./src/version", .{});
    defer file.close();

    try file.writeAll(formatted);
    try file.writeAll("-");
    try file.writeAll(&buffer);  
}

const Date = struct {
    const DAYS_IN_MONTH = [_]u64{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    const START_YEAR: u64 = 1970;
    year: u64,
    month: u64,
    day: u64,

    pub fn now() Date {
        const timestamp = std.time.timestamp();
        var year: u64 = START_YEAR;
        var month: u64 = 0;
        var days: u64 = @intCast(@divTrunc(timestamp, std.time.s_per_day));

        //Calculate year
        while (days >= daysInYear(year)) : (year += 1) {
            days -= daysInYear(year);
        }
        //Calcuate month
        while (days >= DAYS_IN_MONTH[month]) : (month += 1) {
            if(daysInYear(year) == 366 and month == 1) {
                days -= 29;
                continue;
            }
            days -= DAYS_IN_MONTH[month];
        }
        //Remainder is days
        return .{
            .year = year,
            .month = month + 1,
            .day = days + 1,
        };
    }

    pub fn format(self: *Date, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{:0>4}{:0>2}{:0>2}", .{self.year,self.month,self.day});
    }

    fn daysInYear(year: u64) u64 {
        return if((@mod(year, 4) == 0 and @mod(year, 100) != 0) or @mod(year, 400) == 0) 366 else 365;
    }
};

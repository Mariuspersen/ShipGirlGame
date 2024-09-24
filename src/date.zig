const std = @import("std");
const Self = @This();
const DAYS_IN_MONTH = [_]u64{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
const START_YEAR: u64 = 1970;
year: u64,
month: u64,
day: u64,

pub fn now() Self {
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
        if (daysInYear(year) == 366 and month == 1) {
            days -= 29;
        } else {
            days -= DAYS_IN_MONTH[month];
        }
    }
    //Remainder is days
    return .{
        .year = year,
        .month = month + 1,
        .day = days + 1,
    };
}

pub fn format(self: *Self, allocator: std.mem.Allocator) ![]u8 {
    return try std.fmt.allocPrint(
        allocator,
        "{:0>4}{:0>2}{:0>2}",
        .{ self.year, self.month, self.day },
    );
}

fn daysInYear(year: u64) u64 {
    return if ((@mod(year, 4) == 0 and @mod(year, 100) != 0) or @mod(year, 400) == 0) 366 else 365;
}

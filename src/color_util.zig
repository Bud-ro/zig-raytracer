const zm = @import("zmath");
const std = @import("std");

pub fn write_color(out: anytype, pixel_color: zm.F32x4) !void {
    const ir: i16 = @intFromFloat(255.999 * pixel_color[0]);
    const ig: i16 = @intFromFloat(255.999 * pixel_color[1]);
    const ib: i16 = @intFromFloat(255.999 * pixel_color[2]);

    try out.print("{} {} {}\n", .{ ir, ig, ib });
}

const std = @import("std");
const zm = @import("zmath");
const color_util = @import("color_util.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw_out = std.io.bufferedWriter(stdout_file);
    const stdout = bw_out.writer();

    const stderr_file = std.io.getStdErr().writer();
    var bw_err = std.io.bufferedWriter(stderr_file);
    const stderr = bw_err.writer();

    const image_width = 256;
    const image_height = 256;

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    for (0..image_width) |j| {
        try stderr.print("\rScanlines remaining {} ", .{image_height - j});
        try bw_err.flush();
        for (0..image_height) |i| {
            const r: f32 = @as(f32, @floatFromInt(i)) / (image_width - 1);
            const g: f32 = @as(f32, @floatFromInt(j)) / (image_height - 1);
            const b: f32 = @as(f32, @floatFromInt(0));
            const color = zm.F32x4{ r, g, b, 0 };

            try color_util.write_color(stdout, color);
        }
    }

    try stderr.print("\rDone.                    \n ", .{});
    try bw_err.flush();
    try bw_out.flush(); // Flush the rest of the output!
}

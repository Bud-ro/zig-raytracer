const std = @import("std");
const zm = @import("zmath");

fn linear_to_gamma(linear_component: f32) f32 {
    return std.math.sqrt(linear_component);
}

pub fn writeColor(out: anytype, pixel_color: zm.F32x4, samples_per_pixel: usize) !void {
    const r = pixel_color[0];
    const g = pixel_color[1];
    const b = pixel_color[2];

    // Scale the pixel color by the number of samples
    const scale: f32 = 1.0 / @as(f32, @floatFromInt(samples_per_pixel));

    const ir: f32 = std.math.clamp(r * scale, 0.000, 0.999);
    const ig: f32 = std.math.clamp(g * scale, 0.000, 0.999);
    const ib: f32 = std.math.clamp(b * scale, 0.000, 0.999);

    try out.print("{} {} {}\n", .{
        @as(i16, @intFromFloat(256 * linear_to_gamma(ir))),
        @as(i16, @intFromFloat(256 * linear_to_gamma(ig))),
        @as(i16, @intFromFloat(256 * linear_to_gamma(ib))),
    });
}

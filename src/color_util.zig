const std = @import("std");
const zm = @import("zmath");

fn rand_range(rnd: std.rand.Random, min: f32, max: f32) f32 {
    return min + (max - min) * rnd.float(f32);
}

fn linear_to_gamma(linear_component: f32) f32 {
    return std.math.sqrt(linear_component);
}

pub fn random_color(rnd: std.rand.Random) zm.F32x4 {
    return zm.F32x4{ rnd.float(f32), rnd.float(f32), rnd.float(f32), 0 };
}

pub fn random_color_range(rnd: std.rand.Random, min: f32, max: f32) zm.F32x4 {
    return zm.f32x4(rand_range(rnd, min, max), rand_range(rnd, min, max), rand_range(rnd, min, max), 0.0);
}

pub fn writeColor(out: anytype, pixel_color: zm.F32x4) !void {
    const r = pixel_color[0];
    const g = pixel_color[1];
    const b = pixel_color[2];

    const ir: f32 = std.math.clamp(r, 0.000, 0.999);
    const ig: f32 = std.math.clamp(g, 0.000, 0.999);
    const ib: f32 = std.math.clamp(b, 0.000, 0.999);

    try out.print("{} {} {}\n", .{
        @as(i16, @intFromFloat(256 * linear_to_gamma(ir))),
        @as(i16, @intFromFloat(256 * linear_to_gamma(ig))),
        @as(i16, @intFromFloat(256 * linear_to_gamma(ib))),
    });
}

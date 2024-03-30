const std = @import("std");
const zm = @import("zmath");
const Ray = @import("ray.zig").Ray;
const color_util = @import("color_util.zig");

pub fn hit_sphere(center: zm.F32x4, radius: f32, r: Ray) bool {
    const oc = r.orig - center;
    const a = zm.dot4(r.dir, r.dir);
    const b = zm.f32x4s(2.0) * zm.dot4(oc, r.dir);
    const c = zm.dot4(oc, oc) - zm.f32x4s(radius * radius);
    const discriminant = b * b - zm.f32x4s(4) * a * c;

    return (discriminant[0] >= 0); // All components should be the same
}

pub fn rayColor(r: Ray) zm.F32x4 {
    if (hit_sphere(zm.F32x4{ 0, 0, -1, 0 }, 0.5, r)) {
        return zm.F32x4{ 1, 0, 0, 0 }; // Return red if we hit the sphere
    }

    const unit_direction: zm.F32x4 = zm.normalize4(r.dir);
    const a = zm.f32x4s(0.5) * (zm.f32x4s(unit_direction[1]) + zm.f32x4s(1.0));
    return (zm.f32x4s(1.0) - a) * zm.F32x4{ 1.0, 1.0, 1.0, 0 } + a * zm.F32x4{ 0.5, 0.7, 1.0, 0 };
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw_out = std.io.bufferedWriter(stdout_file);
    const stdout = bw_out.writer();

    const stderr_file = std.io.getStdErr().writer();
    var bw_err = std.io.bufferedWriter(stderr_file);
    const stderr = bw_err.writer();

    // Image

    const aspect_ratio = 16.0 / 9.0;
    const image_width: comptime_int = 400;
    const image_height: comptime_int = @max(@as(comptime_int, @intFromFloat(@as(comptime_float, @floatFromInt(image_width)) / aspect_ratio)), 1); // Minimum image height is 1

    // Camera
    // We use a right handed system with the basis vectors
    // -z pointing into the viewport, positive y upwards, and positive x pointing to the right

    const focal_length = 1.0;
    const viewport_height: comptime_float = 2.0;
    const viewport_width: comptime_float = viewport_height * (@as(comptime_float, @floatFromInt(image_width)) / @as(comptime_float, @floatFromInt(image_height)));
    const camera_center = zm.f32x4s(0); // (0,0,0)

    // Calculate the vectors across hte horizontal and down the vertical viewport edges
    const viewport_u = zm.F32x4{ viewport_width, 0, 0, 0 };
    const viewport_v = zm.F32x4{ 0, -viewport_height, 0, 0 };

    // Calculuate the horizontal and vertical delta vectors from pixel to pixel
    const pixel_delta_u = viewport_u / zm.f32x4s(image_width);
    const pixel_delta_v = viewport_v / zm.f32x4s(image_height);

    // Calculate the location of the upper left pixel
    const viewport_upper_left = camera_center - zm.F32x4{ 0, 0, focal_length, 0 } - (viewport_u + viewport_v) / zm.f32x4s(2);
    const pixel00_loc = viewport_upper_left + (pixel_delta_u + pixel_delta_v) / zm.f32x4s(2);

    // Render

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        try stderr.print("\rScanlines remaining {} ", .{image_height - j});
        try bw_err.flush();
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc + (zm.f32x4s(@floatFromInt(i)) * pixel_delta_u) + (zm.f32x4s(@floatFromInt(j)) * pixel_delta_v);
            const ray_direction = pixel_center - camera_center;
            const r = Ray{ .orig = camera_center, .dir = ray_direction };

            const color = rayColor(r);
            try color_util.writeColor(stdout, color);
        }
    }

    try stderr.print("\rDone.                    \n ", .{});
    try bw_err.flush();
    try bw_out.flush(); // Flush the rest of the output!
}

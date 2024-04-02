const std = @import("std");
const zm = @import("zmath");
const Ray = @import("ray.zig").Ray;
const Interval = @import("interval.zig");
const color_util = @import("color_util.zig");
const hittable = @import("hittable/hittable.zig");
const HittableList = @import("hittable/hittable_list.zig").HittableList;
const Sphere = @import("hittable/sphere.zig").Sphere;

pub fn rayColor(r: Ray, world: hittable.IHittable) zm.F32x4 {
    var rec: hittable.HitRecord = undefined;

    if (world.hit(r, Interval.init(0.0, std.math.inf(f32)), &rec)) {
        return zm.f32x4s(0.5) * (rec.normal + zm.f32x4s(1));
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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Image

    const aspect_ratio = 16.0 / 9.0;
    const image_width: comptime_int = 400;
    const image_height: comptime_int = @max(@as(comptime_int, @intFromFloat(@as(comptime_float, @floatFromInt(image_width)) / aspect_ratio)), 1); // Minimum image height is 1

    // World

    var world = HittableList.init(allocator);
    defer world.deinit();

    // TODO: These copy so maybe pass in pointers or construct in-place (emplace) instead?
    var sphere1: Sphere = .{ .center = zm.F32x4{ 0, 0, -1, 0 }, .radius = zm.f32x4s(0.5) };
    try world.add(sphere1.interface());

    var sphere2: Sphere = .{ .center = zm.F32x4{ 0, -100.5, -1, 0 }, .radius = zm.f32x4s(100) };
    try world.add(sphere2.interface());

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

            const color = rayColor(r, world.interface());
            try color_util.writeColor(stdout, color);
        }
    }

    try stderr.print("\rDone.                    \n ", .{});
    try bw_err.flush();
    try bw_out.flush(); // Flush the rest of the output!
}

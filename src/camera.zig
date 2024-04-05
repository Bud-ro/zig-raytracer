//! Camera code
//! Uses a right handed system with the basis vectors
//! -z pointing into the viewport, positive y upwards, and positive x pointing to the right

const std = @import("std");
const hittable = @import("hittable/hittable.zig");
const zm = @import("zmath");
const Ray = @import("ray.zig");
const Interval = @import("interval.zig");
const color_util = @import("color_util.zig");
const vector_util = @import("vector_util.zig");
const IMaterial = @import("/material/material.zig");

const Camera = @This();

// These fields are treated as public
/// Width of the image
image_width: usize,
/// Aspect Ratio
aspect_ratio: f32,
/// Samples Per Pixel
samples_per_pixel: usize,
/// Xorshiro Random Number Generator
rnd: std.rand.Random = undefined,
/// Max number of bounces
max_depth: usize = 10,
/// Vertical view angle
vfov: f32 = 90,
/// Point camera is looking from
lookfrom: zm.F32x4 = undefined,
/// Point camera is looking at
lookat: zm.F32x4 = undefined,
/// Camera-relative "up" direction
vup: zm.F32x4 = zm.F32x4{ 0, 1, 0, 0 },

// These should all be treated as private to the camera instance
/// Height of the image
image_height: usize = undefined,
/// Camera center
center: zm.F32x4 = undefined,
/// Location of pixel (0,0)
pixel00_loc: zm.F32x4 = undefined,
/// Offset to pixel to the right
pixel_delta_u: zm.F32x4 = undefined,
/// Offset to pixel below
pixel_delta_v: zm.F32x4 = undefined,
// Camera frame basis vectors
u: zm.F32x4 = undefined,
v: zm.F32x4 = undefined,
w: zm.F32x4 = undefined,

pub fn render(self: *Camera, world: hittable.IHittable) !void {
    initialize(self);

    const stdout_file = std.io.getStdOut().writer();
    var bw_out = std.io.bufferedWriter(stdout_file);
    const stdout = bw_out.writer();

    const stderr_file = std.io.getStdErr().writer();
    var bw_err = std.io.bufferedWriter(stderr_file);
    const stderr = bw_err.writer();

    try stdout.print("P3\n{} {}\n255\n", .{ self.image_width, self.image_height });

    for (0..self.image_height) |j| {
        try stderr.print("\rScanlines remaining {} ", .{self.image_height - j});
        try bw_err.flush();
        for (0..self.image_width) |i| {
            var pixel_color = zm.f32x4s(0.0);
            for (0..self.samples_per_pixel) |sample| {
                _ = sample;
                var r = get_ray(self, i, j);
                pixel_color += ray_color(self, r, self.max_depth, world);
            }

            try color_util.writeColor(stdout, pixel_color, self.samples_per_pixel);
        }
    }

    try stderr.print("\rDone.                    \n ", .{});
    try bw_err.flush(); // Flush the rest of the output!
    try bw_out.flush();
}

fn initialize(self: *Camera) void {
    self.image_height = @max(@as(usize, @intFromFloat(@as(f32, @floatFromInt(self.image_width)) / self.aspect_ratio)), 1); // Minimum image height is 1

    self.center = self.lookfrom;

    // Determine viewport dimensions
    const focal_length: f32 = zm.length4(self.lookfrom - self.lookat)[0];
    const theta = std.math.degreesToRadians(f32, self.vfov);
    const h = @tan(theta / 2.0);
    const viewport_height = 2.0 * h * focal_length;
    const viewport_width: f32 = viewport_height * (@as(f32, @floatFromInt(self.image_width)) / @as(f32, @floatFromInt(self.image_height)));

    // Calculate the u,v,w unit basis vectors for the camera coordinate frame
    self.w = zm.normalize4(self.lookfrom - self.lookat);
    self.u = zm.normalize4(zm.cross3(self.vup, self.w));
    self.v = zm.cross3(self.w, self.u);

    // Calculate the vectors across hte horizontal and down the vertical viewport edges
    const viewport_u = zm.f32x4s(viewport_width) * self.u;
    const viewport_v = zm.f32x4s(-viewport_height) * self.v;

    // Calculuate the horizontal and vertical delta vectors from pixel to pixel
    self.pixel_delta_u = viewport_u / zm.f32x4s(@as(f32, @floatFromInt(self.image_width)));
    self.pixel_delta_v = viewport_v / zm.f32x4s(@as(f32, @floatFromInt(self.image_height)));

    // Calculate the location of the upper left pixel
    const viewport_upper_left = self.center - (zm.f32x4s(focal_length) * self.w) - (viewport_u + viewport_v) / zm.f32x4s(2);
    self.pixel00_loc = viewport_upper_left + (self.pixel_delta_u + self.pixel_delta_v) / zm.f32x4s(2);
}

fn get_ray(self: *Camera, i: usize, j: usize) Ray {
    const pixel_center = self.pixel00_loc + (zm.f32x4s(@floatFromInt(i)) * self.pixel_delta_u) + (zm.f32x4s(@floatFromInt(j)) * self.pixel_delta_v);
    const pixel_sample = pixel_center + pixel_sample_square(self);

    var ray_origin = self.center;
    const ray_direction = pixel_sample - ray_origin;

    return Ray{ .orig = ray_origin, .dir = ray_direction };
}

fn pixel_sample_square(self: *Camera) zm.F32x4 {
    const px = zm.f32x4s(-0.5 + self.rnd.float(f32));
    const py = zm.f32x4s(-0.5 + self.rnd.float(f32));

    return (px * self.pixel_delta_u) + (py * self.pixel_delta_v);
}

fn ray_color(self: *Camera, r: Ray, depth: usize, world: hittable.IHittable) zm.F32x4 {
    var rec: hittable.HitRecord = undefined;

    if (depth <= 0) {
        return zm.F32x4{ 0, 0, 0, 0 };
    }

    if (world.hit(r, Interval.init(0.001, std.math.inf(f32)), &rec)) {
        var scattered: Ray = undefined;
        var attenuation: zm.F32x4 = undefined;

        if (rec.mat.scatter(r, &rec, &attenuation, &scattered)) {
            return attenuation * ray_color(self, scattered, depth - 1, world);
        }
        return zm.f32x4s(0);
    }

    const unit_direction: zm.F32x4 = zm.normalize4(r.dir);
    const a = zm.f32x4s(0.5) * (zm.f32x4s(unit_direction[1]) + zm.f32x4s(1.0));
    return (zm.f32x4s(1.0) - a) * zm.F32x4{ 1.0, 1.0, 1.0, 0 } + a * zm.F32x4{ 0.5, 0.7, 1.0, 0 };
}

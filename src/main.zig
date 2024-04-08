const std = @import("std");
const zm = @import("zmath");
const Camera = @import("camera.zig");
const Hittable = @import("hittable/hittable.zig").Hittable;
const Material = @import("material/material.zig").Material;
const color_util = @import("color_util.zig");

fn rand_range(rnd: std.rand.Random, min: f32, max: f32) f32 {
    return min + (max - min) * rnd.float(f32);
}

pub fn main() !void {
    const start_time = std.time.milliTimestamp();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var rnd = std.rand.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const random = rnd.random();

    // Initialize the world
    var hittable_list = std.ArrayList(Hittable).init(allocator);
    defer hittable_list.deinit();

    var material_ground = Material{ .lambertian = .{ .albedo = zm.F32x4{ 0.5, 0.5, 0.5, 0.0 }, .rnd = random } };
    var ground_sphere = Hittable{ .sphere = .{ .center = zm.F32x4{ 0.0, -1000, 0, 0.0 }, .radius = zm.f32x4s(1000), .mat = material_ground } };
    try hittable_list.append(ground_sphere);

    var a: i32 = -11;
    while (a < 11) {
        a += 1;
        var b: i32 = -11;
        while (b < 11) {
            b += 1;
            const choose_mat = random.float(f32);
            const center = zm.f32x4(
                @as(f32, @floatFromInt(a)) + 0.9 * random.float(f32),
                0.2,
                @as(f32, @floatFromInt(b)) + 0.9 * random.float(f32),
                0,
            );

            if (zm.any(zm.length4(center - zm.F32x4{ 4, 0.2, 0, 0 }) > zm.f32x4s(0.9), 4)) {
                if (choose_mat < 0.8) {
                    // Diffuse
                    const albedo = color_util.random_color(random) * color_util.random_color(random);
                    const material = Material{ .lambertian = .{ .albedo = albedo, .rnd = random } };
                    var sphere = Hittable{ .sphere = .{ .center = center, .radius = zm.f32x4s(0.2), .mat = material } };
                    try hittable_list.append(sphere);
                } else if (choose_mat < 0.95) {
                    // Metal
                    const albedo = color_util.random_color_range(random, 0.5, 1.0);
                    const fuzz = rand_range(random, 0, 0.5);
                    const material = Material{ .metal = .{ .albedo = albedo, .fuzz = fuzz, .rnd = random } };
                    var sphere = Hittable{ .sphere = .{ .center = center, .radius = zm.f32x4s(0.2), .mat = material } };
                    try hittable_list.append(sphere);
                } else {
                    // Glass
                    const material = Material{ .dielectric = .{ .ir = 1.5, .rnd = random } };
                    var sphere = Hittable{ .sphere = .{ .center = center, .radius = zm.f32x4s(0.2), .mat = material } };
                    try hittable_list.append(sphere);
                }
            }
        }
    }

    const material1 = Material{ .dielectric = .{ .ir = 1.5, .rnd = random } };
    try hittable_list.append(Hittable{ .sphere = .{ .center = zm.F32x4{ 0, 1, 0, 0 }, .radius = zm.f32x4s(1.0), .mat = material1 } });

    const material2 = Material{ .lambertian = .{ .albedo = zm.F32x4{ 0.4, 0.2, 0.1, 0 }, .rnd = random } };
    try hittable_list.append(Hittable{ .sphere = .{ .center = zm.F32x4{ -4, 1, 0, 0 }, .radius = zm.f32x4s(1.0), .mat = material2 } });

    const material3 = Material{ .metal = .{ .albedo = zm.F32x4{ 0.7, 0.6, 0.5, 0.0 }, .fuzz = 0.0, .rnd = random } };
    try hittable_list.append(Hittable{ .sphere = .{ .center = zm.F32x4{ 4, 1, 0, 0 }, .radius = zm.f32x4s(1.0), .mat = material3 } });

    var camera: Camera = .{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 1200,
        .samples_per_pixel = 5,
        .max_depth = 50,
        .rnd = random,
        .vfov = 20,
        .lookfrom = zm.F32x4{ 13, 2, 3, 0 },
        .lookat = zm.F32x4{ 0, 0, 0, 0 },
        .defocus_angle = 0.6,
        .focus_dist = 10.0,
    };

    var world = Hittable{ .hittable_list = .{ .objects = &hittable_list } };
    // defer world.deinit();

    try camera.render(world);

    const stderr_file = std.io.getStdErr().writer();
    var bw_err = std.io.bufferedWriter(stderr_file);
    const stderr = bw_err.writer();

    try stderr.print("Took {} milliseconds to render", .{std.time.milliTimestamp() - start_time});
    try bw_err.flush();
}

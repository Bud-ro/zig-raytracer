const std = @import("std");
const zm = @import("zmath");
const Camera = @import("camera.zig");
const HittableList = @import("hittable/hittable_list.zig");
const Sphere = @import("hittable/sphere.zig");
const Lambertian = @import("material/lambertian.zig");
const Metal = @import("material/metal.zig");
const Dielectric = @import("material/dielectric.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var rnd = std.rand.DefaultPrng.init(@intCast(std.time.microTimestamp()));

    var world = HittableList.init(allocator);
    defer world.deinit();

    const R: f32 = @cos(std.math.pi / 4.0);

    var material_left = Lambertian{ .albedo = zm.F32x4{ 0, 0, 1, 0.0 }, .rnd = rnd.random() };
    var material_right = Lambertian{ .albedo = zm.F32x4{ 1, 0, 0, 0.0 }, .rnd = rnd.random() };

    // TODO: These copy so maybe pass in pointers or construct in-place (emplace) instead?
    var left_sphere = Sphere{ .center = zm.F32x4{ -R, 0.0, -1.0, 0.0 }, .radius = zm.f32x4s(R), .mat = material_left.interface() };
    try world.add(left_sphere.interface());

    var right_sphere = Sphere{ .center = zm.F32x4{ R, 0.0, -1.0, 0.0 }, .radius = zm.f32x4s(R), .mat = material_right.interface() };
    try world.add(right_sphere.interface());

    const aspect_ratio = 16.0 / 9.0;
    var camera = Camera{ .aspect_ratio = aspect_ratio, .image_width = 400, .samples_per_pixel = 100, .max_depth = 50, .rnd = rnd.random(), .vfov = 90 };

    try camera.render(world.interface());
}

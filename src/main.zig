const std = @import("std");
const zm = @import("zmath");
const Camera = @import("camera.zig");
const HittableList = @import("hittable/hittable_list.zig");
const Sphere = @import("hittable/sphere.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var world = HittableList.init(allocator);
    defer world.deinit();

    // TODO: These copy so maybe pass in pointers or construct in-place (emplace) instead?
    var sphere1: Sphere = .{ .center = zm.F32x4{ 0, 0, -1, 0 }, .radius = zm.f32x4s(0.5) };
    try world.add(sphere1.interface());

    var sphere2: Sphere = .{ .center = zm.F32x4{ 0, -100.5, -1, 0 }, .radius = zm.f32x4s(100) };
    try world.add(sphere2.interface());

    const aspect_ratio = 16.0 / 9.0;
    var camera = Camera{ .aspect_ratio = aspect_ratio, .image_width = 400, .samples_per_pixel = 100 };

    try camera.render(world.interface());
}

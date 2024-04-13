//! Metal Material class
//! This material reflects like a mirror
//! Also allows for a tweakable amount of fuzz

const std = @import("std");
const zm = @import("zmath");
const hittable = @import("../hittable/hittable.zig");
const Ray = @import("../ray.zig");
const vector_util = @import("../vector_util.zig");

/// Color that we attenuate the light by.
albedo: zm.F32x4,
/// Fuzz Parameter
fuzz: f32,
/// Pass in a reference to a random number generator
rnd: std.rand.Random,

const Metal = @This();

pub fn scatter(self: Metal, r_in: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
    const reflected = vector_util.reflect(zm.normalize4(r_in.dir), rec.normal);
    scattered.* = Ray{ .orig = rec.p, .dir = reflected + zm.f32x4s(self.fuzz) * vector_util.random_unit_vector(self.rnd), .tm = r_in.tm };
    attenuation.* = self.albedo;
    return zm.dot4(scattered.dir, rec.normal)[0] > 0;
}

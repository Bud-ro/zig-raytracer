//! Metal Material class
//! This material reflects like a mirror
//! Also allows for a tweakable amount of fuzz

const std = @import("std");
const zm = @import("zmath");
const IMaterial = @import("material.zig");
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

pub fn interface(self: *Metal) IMaterial {
    return .{
        .impl = @as(*anyopaque, @ptrCast(self)),
        .scatterFn = scatter,
    };
}

pub fn scatter(self_opaque: *anyopaque, r_in: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
    var self = @as(*Metal, @ptrCast(@alignCast(self_opaque)));

    const reflected = vector_util.reflect(zm.normalize4(r_in.dir), rec.normal);
    scattered.* = Ray{ .orig = rec.p, .dir = reflected + zm.f32x4s(self.fuzz) * vector_util.random_unit_vector(self.rnd) };
    attenuation.* = self.albedo;
    return zm.all(zm.dot4(scattered.dir, rec.normal) > zm.f32x4s(0), 4);
}

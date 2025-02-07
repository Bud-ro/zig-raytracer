//! Diffuse Material class
//! This material scatters light in a way that is proportional to
//! the cosine of the angle between the normal, and the reflected ray.
//! Rays therefore are most likely to reflect in the same direction
//! as the surface normal.

const std = @import("std");
const zm = @import("zmath");
const hittable = @import("../hittable/hittable.zig");
const Ray = @import("../ray.zig");
const vector_util = @import("../vector_util.zig");

/// Color that we attenuate the light by.
albedo: zm.F32x4,
/// Pass in a reference to a random number generator
rnd: std.rand.Random,

const Lambertian = @This();

pub fn scatter(self: Lambertian, r_in: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
    var scatter_direction = rec.normal + vector_util.random_unit_vector(self.rnd);

    // Catch degenerate scatter direction
    if (vector_util.near_zero(scatter_direction)) {
        scatter_direction = rec.normal;
    }

    scattered.* = Ray{ .orig = rec.p, .dir = scatter_direction, .tm = r_in.tm };
    attenuation.* = self.albedo;

    // We choose to always scatter, but we could either scatter with probability p, or achieve
    // the same effect by attenuating by albedo/p
    return true;
}

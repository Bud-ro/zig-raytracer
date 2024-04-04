//! Metal Material class
//! This material reflects like a mirror

const std = @import("std");
const zm = @import("zmath");
const IMaterial = @import("material.zig");
const hittable = @import("../hittable/hittable.zig");
const Ray = @import("../ray.zig");
const vector_util = @import("../vector_util.zig");

/// Color that we attenuate the light by.
albedo: zm.F32x4,

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
    scattered.* = Ray{ .orig = rec.p, .dir = reflected };
    attenuation.* = self.albedo;
    return true;
}

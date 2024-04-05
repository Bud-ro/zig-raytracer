const std = @import("std");
const vector_util = @import("../vector_util.zig");
const zm = @import("zmath");
const IMaterial = @import("material.zig");
const Ray = @import("../ray.zig");
const hittable = @import("../hittable/hittable.zig");

const Dielectric = @This();

/// Index of refraction for the material
ir: f32,
/// Pass in a reference to a random number generator
rnd: std.rand.Random,

pub fn interface(self: *Dielectric) IMaterial {
    return .{
        .impl = @as(*anyopaque, @ptrCast(self)),
        .scatterFn = scatter,
    };
}

pub fn scatter(self_opaque: *anyopaque, r_in: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
    var self = @as(*Dielectric, @ptrCast(@alignCast(self_opaque)));

    attenuation.* = zm.F32x4{ 1.0, 1.0, 1.0, 0.0 };
    const refraction_ratio = zm.f32x4s(if (rec.front_face) (1.0 / self.ir) else self.ir);

    const unit_direction = zm.normalize4(r_in.dir);

    const cos_theta = @min(zm.dot4(-unit_direction, rec.normal), zm.f32x4s(1.0));
    const sin_theta = @sqrt(zm.f32x4s(1.0) - zm.dot4(cos_theta, cos_theta));

    const cannot_refract = zm.all(refraction_ratio * sin_theta > zm.f32x4s(1.0), 4);

    const direction = if (cannot_refract or reflectance(cos_theta[0], refraction_ratio[0]) > self.rnd.float(f32))
        vector_util.reflect(unit_direction, rec.normal)
    else
        vector_util.refract(unit_direction, rec.normal, refraction_ratio);

    scattered.* = Ray{ .orig = rec.p, .dir = direction };
    return true;
}

// Schlick's approximation for reflectance
fn reflectance(cosine: f32, ref_idx: f32) f32 {
    var r0 = (1 - ref_idx) / (1 + ref_idx);
    r0 = r0 * r0;
    return r0 + (1 - r0) * std.math.pow(f32, 1 - cosine, 5);
}

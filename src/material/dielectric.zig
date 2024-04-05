const vector_util = @import("../vector_util.zig");
const zm = @import("zmath");
const IMaterial = @import("material.zig");
const Ray = @import("../ray.zig");
const hittable = @import("../hittable/hittable.zig");

const Dielectric = @This();

/// Index of refraction for the material
ir: f32,

pub fn interface(self: *Dielectric) IMaterial {
    return .{
        .impl = @as(*anyopaque, @ptrCast(self)),
        .scatterFn = scatter,
    };
}

pub fn scatter(self_opaque: *anyopaque, r_in: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
    var self = @as(*Dielectric, @ptrCast(@alignCast(self_opaque)));

    attenuation.* = zm.F32x4{ 1.0, 1.0, 1.0, 0.0 };

    var refraction_ratio: f32 = 0.0;
    if (rec.front_face) {
        refraction_ratio = (1.0 / self.ir);
    } else {
        refraction_ratio = self.ir;
    }

    const unit_direction = zm.normalize4(r_in.dir);
    const refracted = vector_util.refract(unit_direction, rec.normal, refraction_ratio);

    scattered.* = Ray{ .orig = rec.p, .dir = refracted };
    return true;
}

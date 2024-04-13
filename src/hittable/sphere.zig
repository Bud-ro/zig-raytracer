const zm = @import("zmath");
const hittable = @import("hittable.zig");
const Interval = @import("../interval.zig");
const Ray = @import("../ray.zig");
const Material = @import("../material/material.zig").Material;

center1: zm.F32x4,
radius: zm.F32x4, // All 4 components must be the same, and should be positive
mat: Material,
is_moving: bool,
center_vec: zm.F32x4 = zm.f32x4s(0.0),

const Sphere = @This();

pub fn hit(self: Sphere, r: Ray, interval: Interval, rec: *hittable.HitRecord) bool {
    const center = if (self.is_moving) sphere_center(self, r.tm) else self.center1;
    const oc = center - r.orig;
    const a = zm.dot4(r.dir, r.dir);
    const h = zm.dot4(r.dir, oc);
    const c = zm.dot4(oc, oc) - self.radius * self.radius;

    const discriminant = h * h - a * c;
    if (discriminant[0] < 0) {
        return false;
    }
    const sqrtd = zm.sqrt(discriminant);

    // Find the nearest root in acceptable range
    var root = ((h - sqrtd) / a)[0];
    if (!interval.surrounds(root)) {
        root = ((h + sqrtd) / a)[0];
        if (!interval.surrounds(root)) {
            return false;
        }
    }

    rec.*.t = root;
    rec.*.p = r.at(rec.*.t);
    const outward_normal = (rec.*.p - center) / self.radius;
    rec.*.set_face_normal(r, outward_normal);
    rec.*.mat = self.mat;

    return true;
}

/// Linearly Interpolates from center1 to center2, where t=0 yields
/// center1, and t=1 yields center2.
fn sphere_center(self: Sphere, time: f32) zm.F32x4 {
    return self.center1 + zm.f32x4s(time) * self.center_vec;
}

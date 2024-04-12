const zm = @import("zmath");
const hittable = @import("hittable.zig");
const Interval = @import("../interval.zig");
const Ray = @import("../ray.zig");
const Material = @import("../material/material.zig").Material;

center: zm.F32x4,
radius: zm.F32x4, // All 4 components must be the same, and should be positive
mat: Material,

const Sphere = @This();

pub fn hit(self: Sphere, r: Ray, interval: Interval, rec: *hittable.HitRecord) bool {
    const oc = self.center - r.orig;
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
    const outward_normal = (rec.*.p - self.center) / self.radius;
    rec.*.set_face_normal(r, outward_normal);
    rec.*.mat = self.mat;

    return true;
}

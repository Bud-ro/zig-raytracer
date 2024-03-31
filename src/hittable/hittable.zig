const zm = @import("zmath");
const Ray = @import("../ray.zig").Ray;

pub const HitRecord = struct {
    p: zm.F32x4,
    normal: zm.F32x4,
    t: zm.F32x4,
    front_face: bool,

    /// Sets the hit record normal vector
    /// NOTE: the parameter `outward_normal` is assumed to have unit length
    pub fn set_face_normal(self: *HitRecord, r: Ray, outward_normal: zm.F32x4) void {
        self.front_face = (zm.dot4(r.dir, outward_normal)[0] < 0.0);
        if (self.front_face) {
            self.normal = outward_normal;
        } else {
            self.normal = -outward_normal;
        }
    }
};

pub const IHittable = struct {
    // The type erased pointer to the hittable implementation
    impl: *anyopaque,

    hitFn: *const fn (*anyopaque, Ray, zm.F32x4, zm.F32x4, *HitRecord) bool,

    pub fn hit(iface: *const IHittable, r: Ray, t_min: zm.F32x4, t_max: zm.F32x4, rec: *HitRecord) bool {
        return iface.hitFn(iface.impl, r, t_min, t_max, rec);
    }
};

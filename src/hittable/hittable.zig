const zm = @import("zmath");
const Ray = @import("../ray.zig");
const Interval = @import("../interval.zig");
const Material = @import("../material/material.zig").Material;
const Sphere = @import("sphere.zig");
const HittableList = @import("hittable_list.zig");

pub const HitRecord = struct {
    p: zm.F32x4,
    normal: zm.F32x4,
    mat: Material,
    t: f32,
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

pub const HittableType = enum {
    sphere,
    hittable_list,
};
pub const Hittable = union(HittableType) {
    sphere: Sphere,
    hittable_list: HittableList,

    pub fn hit(self: Hittable, r: Ray, interval: Interval, rec: *HitRecord) bool {
        switch (self) {
            inline else => |obj| return obj.hit(r, interval, rec),
        }
    }
};

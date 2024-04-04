const zm = @import("zmath");
const Ray = @import("../ray.zig");
const hittable = @import("../hittable/hittable.zig");

const IMaterial = @This();

// The type erased pointer to the hittable implementation
impl: *anyopaque,

scatterFn: *const fn (*anyopaque, Ray, *hittable.HitRecord, *zm.F32x4, *Ray) bool,

pub fn scatter(iface: *const IMaterial, r: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
    return iface.scatterFn(iface.impl, r, rec, attenuation, scattered);
}

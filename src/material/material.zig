const zm = @import("zmath");
const Ray = @import("../ray.zig");
const hittable = @import("../hittable/hittable.zig");
const Lambertian = @import("lambertian.zig");
const Metal = @import("metal.zig");
const Dielectric = @import("dielectric.zig");

pub const MaterialType = enum {
    lambertian,
    metal,
    dielectric,
};
pub const Material = union(MaterialType) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(self: Material, r: Ray, rec: *hittable.HitRecord, attenuation: *zm.F32x4, scattered: *Ray) bool {
        switch (self) {
            // We use duck typing and assume that every valid object has a scatter function associated with it
            inline else => |*obj| return obj.scatter(r, rec, attenuation, scattered),
        }
    }
};

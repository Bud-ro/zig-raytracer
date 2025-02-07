const zm = @import("zmath");

orig: zm.F32x4,
dir: zm.F32x4,
tm: f32,

const Ray = @This();

pub fn at(self: Ray, t: f32) zm.F32x4 {
    return self.orig + self.dir * zm.f32x4s(t);
}

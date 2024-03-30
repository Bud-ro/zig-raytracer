const zm = @import("zmath");

pub const Ray = struct {
    orig: zm.F32x4 = zm.f32x4s(0),
    dir: zm.F32x4 = zm.f32x4s(0),

    pub fn at(self: Ray, t: f32) zm.F32x4 {
        return self.orig + self.dir * zm.f32x4s(t);
    }
};

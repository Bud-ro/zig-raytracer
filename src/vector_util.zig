const std = @import("std");
const zm = @import("zmath");

fn rand_range(rnd: std.rand.Random, min: f32, max: f32) f32 {
    return min + (max - min) * rnd.float(f32);
}

/// Returns a fully random Vec3
pub fn random_vec(rnd: std.rand.Random) zm.F32x4 {
    return zm.f32x4(rnd.float(f32), rnd.float(f32), rnd.float(f32), 0.0);
}

/// Returns a random Vec3 with components that are all clamped to the range given
pub fn clamped_random_vec(rnd: std.rand.Random, min: f32, max: f32) zm.F32x4 {
    return zm.f32x4(rand_range(rnd, min, max), rand_range(rnd, min, max), rand_range(rnd, min, max), 0.0);
}

pub fn random_on_hemisphere(rnd: std.rand.Random, normal: zm.F32x4) zm.F32x4 {
    const on_unit_sphere = random_unit_vector(rnd);
    if (zm.any(zm.dot4(on_unit_sphere, normal) > zm.f32x4s(0.0), 4)) { // In the same hemisphere as the normal
        return on_unit_sphere;
    } else {
        return -on_unit_sphere;
    }
}

/// Returns a random unit vector
pub fn random_unit_vector(rnd: std.rand.Random) zm.F32x4 {
    return zm.normalize4(clamped_random_vec(rnd, -1.0, 1.0));
}

// /// Repeatedly generates Vec3s until one is in the unit sphere
// pub fn random_in_unit_sphere(rnd: std.rand.Random) zm.F32x4 {
//     while (true) {
//         const p = clamped_random_vec(rnd, -1.0, 1.0);
//         if (zm.all(zm.abs(p) < zm.f32x4s(1.0), 4)) {
//             return p;
//         }
//     }
// }

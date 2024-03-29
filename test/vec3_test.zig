const std = @import("std");
const zm = @import("zmath");
// Normally you wouldn't test library code, I just wanted to get some
// initial tests setup and verify the library suits my needs.

test "Vec addition" {
    const v1 = zm.F32x4{ 1, 2, 3, 0 };
    const v2 = zm.F32x4{ 2, 3, 4, 0 };

    const z = v1 + v2;

    try std.testing.expectEqual(z, zm.F32x4{ 3, 5, 7, 0 });
}

test "Vec3 Dot Product" {
    const v1 = zm.F32x4{ 1, 2, 3, 0 };
    const v2 = zm.F32x4{ 2, 3, 4, 0 };

    const z = zm.dot4(v1, v2);

    try std.testing.expectEqual(z, zm.f32x4s(2 + 6 + 12));
}

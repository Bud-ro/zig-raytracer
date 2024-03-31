const std = @import("std");
const zm = @import("zmath");
const hittable = @import("hittable.zig");
const Ray = @import("../ray.zig").Ray;

pub const HittableList = struct {
    objects: std.ArrayList(hittable.IHittable),

    pub fn interface(self: *HittableList) hittable.IHittable {
        return .{
            .impl = @as(*anyopaque, @ptrCast(self)),
            .hitFn = hit,
        };
    }

    pub fn init(allocator: std.mem.Allocator) HittableList {
        var hl = HittableList{ .objects = std.ArrayList(hittable.IHittable).init(allocator) };
        return hl;
    }

    pub fn deinit(self: HittableList) void {
        self.objects.deinit();
    }

    pub fn add(self: *HittableList, object: hittable.IHittable) !void {
        try self.objects.append(object);
    }

    pub fn hit(self_opaque: *anyopaque, r: Ray, t_min: zm.F32x4, t_max: zm.F32x4, rec: *hittable.HitRecord) bool {
        var self = @as(*HittableList, @alignCast(@ptrCast(self_opaque)));

        var temp_rec: hittable.HitRecord = undefined;
        var hit_anything = false;
        var closest_so_far = t_max;

        for (self.objects.items) |object| {
            if (object.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};

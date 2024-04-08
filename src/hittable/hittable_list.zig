const std = @import("std");
const zm = @import("zmath");
const Interval = @import("../interval.zig");
const hittable = @import("hittable.zig");
const Sphere = @import("sphere.zig");
const Ray = @import("../ray.zig");

const HittableList = @This();

objects: *std.ArrayList(Sphere),

pub fn interface(self: *HittableList) hittable.IHittable {
    return .{
        .impl = @as(*anyopaque, @ptrCast(self)),
        .hitFn = hit,
    };
}

// pub fn init(objects: *std.ArrayList(Sphere)) HittableList {
//     var hl = HittableList{ .objects = objects };
//     return hl;
// }

// pub fn deinit(self: HittableList) void {
//     self.objects.deinit();
// }

// pub fn add(self: *HittableList, object: hittable.IHittable) !void {
//     try self.objects.append(object);
// }

pub fn hit(self_opaque: *anyopaque, r: Ray, interval: Interval, rec: *hittable.HitRecord) bool {
    var self = @as(*HittableList, @alignCast(@ptrCast(self_opaque)));

    var temp_rec: hittable.HitRecord = undefined;
    var hit_anything = false;
    var closest_so_far = interval.max;

    for (self.objects.items) |object| {
        if (object.hit(r, Interval.init(interval.min, closest_so_far), &temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec.* = temp_rec;
        }
    }

    return hit_anything;
}

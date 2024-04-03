//! Interval Type

const std = @import("std");

min: f32,
max: f32,

const Interval = @This();

pub fn init(min: f32, max: f32) @This() {
    return .{ .min = min, .max = max };
}

pub fn contains(self: Interval, x: f32) bool {
    return (self.min <= x and x <= self.max);
}

pub fn surrounds(self: Interval, x: f32) bool {
    return (self.min < x and x < self.max);
}

pub fn clamp(self: Interval, x: f32) f32 {
    return std.math.clamp(x, self.min, self.max);
}

pub const empty = Interval{ std.math.inf(f32), -std.math.inf(f32) };
pub const universe = Interval{ -std.math.inf(f32), std.math.inf(f32) };

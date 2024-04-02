//! Interval Type

const std = @import("std");

min: f32,
max: f32,

pub fn init(min: f32, max: f32) @This() {
    return .{ .min = min, .max = max };
}

pub fn contains(self: @This(), x: f32) bool {
    return (self.min <= x and x <= self.max);
}

pub fn surrounds(self: @This(), x: f32) bool {
    return (self.min < x and x < self.max);
}

pub const empty = @This(){ std.math.inf(f32), -std.math.inf(f32) };
pub const universe = @This(){ -std.math.inf(f32), std.math.inf(f32) };

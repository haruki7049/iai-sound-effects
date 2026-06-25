const std = @import("std");

const lightmix = @import("lightmix");

const synthesizers = @import("./synthesizers.zig");
const filters = @import("./filters.zig");
const Scale = @import("./scale.zig");

const SAMPLE_RATE: u32 = 44100;
const CHANNELS: u16 = 2;
const MASTER_VOLUME: T = 0.95;
const T = f64;

pub fn gen(allocator: std.mem.Allocator) !lightmix.Wave(T) {
    const LENGTH: usize = SAMPLE_RATE / 5;

    var whitenoise = try synthesizers.whitenoise.gen(T, allocator, 1.0, LENGTH, SAMPLE_RATE, CHANNELS, 0);

    // Stacking the (linear) decay filter many times turns the fade-out into a
    // much steeper curve, closer to a short, percussive "swoosh" than to a
    // slow linear fade.
    try filters.decay(T, &whitenoise);
    try filters.decay(T, &whitenoise);
    try filters.decay(T, &whitenoise);
    try filters.decay(T, &whitenoise);
    try filters.decay(T, &whitenoise);
    try filters.decay(T, &whitenoise);
    try filters.decay(T, &whitenoise);

    try filters.normalize(T, &whitenoise, MASTER_VOLUME);
    return whitenoise;
}

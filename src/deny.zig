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
    const LENGTH: usize = SAMPLE_RATE / 2;

    const pop_e = try gen_pop(allocator, Scale.gen(.{ .code = .e, .octave = 3 }));
    defer pop_e.deinit();
    const pop_f = try gen_pop(allocator, Scale.gen(.{ .code = .f, .octave = 3 }));
    defer pop_f.deinit();

    var composer = lightmix.Composer(T){ .allocator = allocator, .info = &.{}, .channels = CHANNELS, .sample_rate = SAMPLE_RATE };
    defer composer.deinit();

    try composer.append(.{ .wave = pop_e, .start_point = 0 });
    try composer.append(.{ .wave = pop_f, .start_point = 0 });
    try composer.append(.{ .wave = pop_e, .start_point = LENGTH / 2 });
    try composer.append(.{ .wave = pop_f, .start_point = LENGTH / 2 });

    var w = try composer.finalize(.{});
    try filters.normalize(T, &w, MASTER_VOLUME);
    return w;
}

fn gen_pop(allocator: std.mem.Allocator, frequency: T) !lightmix.Wave(T) {
    const LENGTH: usize = SAMPLE_RATE / 4;

    var samples = try allocator.alloc(T, LENGTH);
    const radians_per_sec_mod: T = frequency * 2.0 * std.math.pi;

    for (0..samples.len) |i| {
        const v: T = std.math.sin(@as(T, @floatFromInt(i)) * radians_per_sec_mod / @as(T, @floatFromInt(SAMPLE_RATE)));
        samples[i] = v;
    }

    var sinewave: lightmix.Wave(T) = lightmix.Wave(T){
        .allocator = allocator,
        .samples = samples,
        .sample_rate = SAMPLE_RATE,
        .channels = CHANNELS,
    };
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.decay(T, &sinewave);
    try filters.normalize(T, &sinewave, MASTER_VOLUME);
    return sinewave;
}

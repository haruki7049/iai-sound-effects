const std = @import("std");
const lightmix = @import("lightmix");

pub const Error = std.mem.Allocator.Error;

pub fn gen(
    comptime T: type,
    allocator: std.mem.Allocator,
    volume: T,
    length: usize,
    frequency: T,
    sample_rate: u32,
    channels: u16,
) Error!lightmix.Wave(T) {
    const radians_per_sec: T = frequency * 2.0 * std.math.pi;
    var samples: []T = try allocator.alloc(T, length * channels);

    for (0..samples.len / channels) |i| {
        for (0..channels) |j| {
            const v: T = std.math.sin(@as(T, @floatFromInt(i)) * radians_per_sec / @as(T, @floatFromInt(sample_rate))) * volume;
            samples[i * channels + j] = v;
        }
    }

    return lightmix.Wave(T){
        .allocator = allocator,
        .samples = samples,
        .channels = channels,
        .sample_rate = sample_rate,
    };
}

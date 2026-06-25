const std = @import("std");
const lightmix = @import("lightmix");

pub const Error = std.mem.Allocator.Error;

/// Generates white noise.
///
/// Every sample is an independent random value in the range [-volume, volume].
/// The same random value is duplicated across all channels for a given sample
/// index (i.e. the noise is identical on every channel, not independently
/// random per channel).
pub fn gen(
    comptime T: type,
    allocator: std.mem.Allocator,
    volume: T,
    length: usize,
    sample_rate: u32,
    channels: u16,
    seed: u64,
) Error!lightmix.Wave(T) {
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    var samples: []T = try allocator.alloc(T, length * channels);

    for (0..length) |i| {
        const v: T = (rand.float(T) * 2.0 - 1.0) * volume;
        for (0..channels) |j| {
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

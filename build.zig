const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) anyerror!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const lightmix = b.dependency("lightmix", .{});

    // Modules
    const mod = b.createModule(.{
        .root_source_file = b.path("src/accept.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    // Static Library Install
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "iai-sound-effects",
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Library linking on Linux
    if (target.result.os.tag == .linux) {
        mod.linkSystemLibrary("alsa", .{});
        mod.linkSystemLibrary("libpulse", .{});
        mod.linkSystemLibrary("libpipewire-0.3", .{});
    }

    // Wave Install
    const wave = try l.addWave(b, mod, .{
        .format = .{ .wav = .{
            .bits = 16,
            .format_code = .pcm,
            .name = "iai-sound-effects.wav",
        } },
    });
    l.installWave(b, wave);
}

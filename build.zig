const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) anyerror!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    try build_mod(b, target, optimize, b.path("src/accept.zig"), "accept.wav");
    try build_mod(b, target, optimize, b.path("src/deny.zig"), "deny.wav");
}

fn build_mod(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    lazypath: std.Build.LazyPath,
    name: []const u8,
) !void {
    // Dependencies
    const lightmix = b.dependency("lightmix", .{});

    // Modules
    const mod = b.createModule(.{
        .root_source_file = lazypath,
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    // Library linking on Linux
    if (target.result.os.tag == .linux) {
        mod.linkSystemLibrary("alsa", .{});
        mod.linkSystemLibrary("libpulse", .{});
        mod.linkSystemLibrary("libpipewire-0.3", .{});
    }

    // Static Library Install
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = name,
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Wave Install
    const wave = try l.addWave(b, mod, .{
        .format = .{ .wav = .{
            .bits = 16,
            .format_code = .pcm,
            .name = name,
        } },
    });
    l.installWave(b, wave);
}

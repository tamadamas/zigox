const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "zigox",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Tests

    const tests = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .test_runner = .{ .path = b.path("test_runner.zig"), .mode = .simple },
        .root_source_file = b.path("src/main.zig"),
    });

    b.step("test", "Run unit tests").dependOn(&b.addRunArtifact(tests).step);
}

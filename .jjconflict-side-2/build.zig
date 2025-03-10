const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const single_threaded = b.option(bool, "single-threaded", "Build a single threaded Executable");
    const test_filters = b.option([]const []const u8, "test-filter", "Skip tests that do not match filter") orelse &.{};
    const use_llvm = b.option(bool, "use-llvm", "Use Zig's llvm code backend");

    const mockHomeOption = b.option([]const u8, "mock-home-path", "Path to mocked home folder") orelse "";

    const exe_options = blk: {
        const exe_options = b.addOptions();
        exe_options.step.name = "Zigox exe options";

        exe_options.addOption([]const u8, "mock_home", mockHomeOption);
        exe_options.addOption(bool, "debug_gpa", b.option(bool, "debug-allocator", "Force the DebugAllocator to be used in all release modes") orelse false);

        break :blk exe_options.createModule();
    };

    const test_options = blk: {
        const test_options = b.addOptions();
        test_options.step.name = "Zigox test options";

        test_options.addOption([]const u8, "mock_home", mockHomeOption);
        break :blk test_options.createModule();
    };

    const known_folders_module = b.dependency("known_folders", .{}).module("known-folders");

    const exe_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize, .single_threaded = single_threaded, .imports = &.{
        .{ .name = "exe_options", .module = exe_options },
        .{ .name = "known-folders", .module = known_folders_module },
    } });

    const exe = b.addExecutable(.{
        .name = "zigox",
        .root_module = exe_module,
        .use_llvm = use_llvm,
        .use_lld = use_llvm,
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
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/tests.zig"),
            .target = target,
            .optimize = optimize,
            .single_threaded = single_threaded,
            .imports = &.{
                .{ .name = "test_options", .module = test_options },
            },
        }),
        .filters = test_filters,
        .use_llvm = use_llvm,
        .use_lld = use_llvm,
        .test_runner = .{ .path = b.path("test_runner.zig"), .mode = .simple },
    });

    const src_tests = b.addTest(.{
        .name = "src test",
        .root_module = exe_module,
        .filters = test_filters,
        .use_llvm = use_llvm,
        .use_lld = use_llvm,
        .test_runner = .{ .path = b.path("test_runner.zig"), .mode = .simple },
    });

    const test_step = b.step("test", "Run all the tests");

    const run_tests = b.addRunArtifact(tests);
    const run_src_tests = b.addRunArtifact(src_tests);

    test_step.dependOn(&run_tests.step);
    test_step.dependOn(&run_src_tests.step);
}

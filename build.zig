const std = @import("std");

pub fn build(b: *std.Build) !void {
    const minhook = b.dependency("minhook", .{});

    const mod = b.addModule("minhook", .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
        .root_source_file = b.path("minhook.zig"),
    });

    const lib = b.addLibrary(.{
        .name = "minhook",
        .linkage = .static,
        .root_module = mod
    });

    lib.linkLibC();
    lib.addIncludePath(minhook.path("include"));
    lib.addCSourceFile(.{ .file = minhook.path("src/buffer.c"), .flags = &.{} });
    lib.addCSourceFile(.{ .file = minhook.path("src/hook.c"), .flags = &.{} });
    lib.addCSourceFile(.{ .file = minhook.path("src/trampoline.c"), .flags = &.{} });
    lib.addCSourceFile(.{ .file = minhook.path("src/hde/hde32.c"), .flags = &.{} });
    lib.addCSourceFile(.{ .file = minhook.path("src/hde/hde64.c"), .flags = &.{} });

    b.installArtifact(lib);


    const minhook_test = b.addTest(.{
        .name = "minhook-test",
        .root_module = mod
    });

    // minhook_test.linkLibrary(lib);

    const test_step = b.step("test", "test minhook bindings");
    test_step.dependOn(&b.addRunArtifact(minhook_test).step);
}

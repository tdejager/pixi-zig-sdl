const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // This creates an executable
    const exe = b.addExecutable(.{
        .name = "zig_sdl",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add the library as a module to the executable
    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
    });
    exe.root_module.addImport("zig_sdl_lib", lib_module);
    configureSDL3Mod(b, lib_module);

    // Configure SDL3 for the executable
    configureSDL3(b, exe);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Configure SDL3 for library tests
    configureSDL3(b, lib_unit_tests);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add the library module to the executable tests
    // exe_unit_tests.root_module.addImport("zig_sdl_lib", lib_module);

    // Configure SDL3 for executable tests
    configureSDL3(b, exe_unit_tests);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

const EnvPaths = struct {
    includePath: []const u8,
    libraryPath: []const u8,
};

fn getLibraryAndIncludePath(b: *std.Build) ?EnvPaths {
    // Try to detect pixi environment and add paths
    if (std.process.getEnvVarOwned(b.allocator, "CONDA_PREFIX")) |conda_prefix| {
        defer b.allocator.free(conda_prefix);

        // Add include path for SDL3 headers
        const include_path = std.fs.path.join(b.allocator, &.{ conda_prefix, "include" }) catch {
            std.debug.print("Failed to create include path\n", .{});
            return null;
        };

        // Add library path
        const lib_path = std.fs.path.join(b.allocator, &.{ conda_prefix, "lib" }) catch {
            std.debug.print("Failed to create library path\n", .{});
            return null;
        };

        return EnvPaths{
            .includePath = include_path,
            .libraryPath = lib_path,
        };
    } else |_| {
        return null; // No pixi environment detected
    }
}

/// Configure SDL3 linking and include paths for a compile step
fn configureSDL3(b: *std.Build, compile: *std.Build.Step.Compile) void {
    // Link against SDL3 and C library
    compile.linkSystemLibrary("SDL3");
    compile.linkLibC();
    const paths = getLibraryAndIncludePath(b);

    if (paths) |p| {
        // Add include path for SDL3 headers
        compile.addIncludePath(.{ .cwd_relative = p.includePath });

        // Add library path
        compile.addLibraryPath(.{ .cwd_relative = p.libraryPath });

        // std.debug.print("Include path: {s}\n", .{p.includePath});
        // std.debug.print("Library path: {s}\n", .{p.libraryPath});
    } else {
        std.debug.print("Error: No pixi environment detected", .{});
    }
}

/// Configure SDL3 linking and include paths for a compile step
fn configureSDL3Mod(b: *std.Build, compile: *std.Build.Module) void {
    const paths = getLibraryAndIncludePath(b);

    if (paths) |p| {
        // Add include path for SDL3 headers
        compile.addIncludePath(.{ .cwd_relative = p.includePath });

        // Add library path
        compile.addLibraryPath(.{ .cwd_relative = p.libraryPath });

        // std.debug.print("Include path: {s}\n", .{p.includePath});
        // std.debug.print("Library path: {s}\n", .{p.libraryPath});
    } else {
        std.debug.print("Error: No pixi environment detected", .{});
    }
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("zig_http", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "zig_http",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zig_http", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const main_tests = b.addTest(.{
        .root_module = mod,
    });
    const method_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zig_http/utils/find_method.zig"),
            .target = target,
        }),
    });
    const route_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zig_http/utils/find_route.zig"),
            .target = target,
        }),
    });
    const headers_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zig_http/utils/find_headers.zig"),
            .target = target,
        }),
    });
    const http_version_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zig_http/utils/find_http_version.zig"),
            .target = target,
        }),
    });
    const http_params_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zig_http/utils/find_params.zig"),
            .target = target,
        }),
    });

    const run_method_tests = b.addRunArtifact(method_tests);
    const run_route_tests = b.addRunArtifact(route_tests);
    const run_headers_tests = b.addRunArtifact(headers_tests);
    const run_http_verion_tests = b.addRunArtifact(http_version_tests);
    const run_http_params_tests = b.addRunArtifact(http_params_tests);

    const run_mod_tests = b.addRunArtifact(main_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    run_method_tests.skip_foreign_checks = true;
    run_route_tests.skip_foreign_checks = true;
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(&run_method_tests.step);
    test_step.dependOn(&run_route_tests.step);
    test_step.dependOn(&run_headers_tests.step);
    test_step.dependOn(&run_http_verion_tests.step);
    test_step.dependOn(&run_http_params_tests.step);

    const exe_check = b.addExecutable(.{
        .name = "zig_http",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .imports = &.{
                .{ .name = "zig_http", .module = mod },
            },
            .target = target,
            .optimize = optimize,
        }),
    });
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&exe_check.step);
}

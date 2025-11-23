const std = @import("std");
const net = @import("std").net;
const posix = @import("std").posix;

const utils = @import("zig_http").utils;
const middleware = @import("zig_http").middleware;
const webserver = @import("zig_http").webserver;

const TPE: u32 = posix.SOCK.STREAM;
const PROTOCOL = posix.IPPROTO.TCP;
const ADDRESS = "127.0.0.1";
const PORT = 5678;
const SIZE: u16 = 1024;

const routes = struct {
    const _routes = @import("zig_http").routes;

    pub const not_found = middleware.log(_routes.not_found);
    pub const path = middleware.log(_routes.path);
    pub const echo = middleware.log(_routes.echo);
};

const Routes = enum {
    path,
    echo,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var _req: [SIZE]u8 = undefined;
    var _res: [SIZE]u8 = undefined;
    std.debug.print("Listening on {s}:{d}\n", .{ ADDRESS, PORT });
    var server = try webserver.Server(SIZE).init(ADDRESS, PORT, &_req, &_res);
    try server.loop(allocator, loop);
    server.deinit();
}

fn loop(_: std.mem.Allocator, request: utils.Request, response: *utils.Response) !void {
    const route = std.meta.stringToEnum(Routes, request.route[1..]) orelse {
        routes.not_found(request, response) catch return;
        return;
    };

    switch (route) {
        .path => routes.path(request, response) catch {
            return;
        },
        .echo => routes.echo(request, response) catch {
            return;
        },
    }

    return;
}

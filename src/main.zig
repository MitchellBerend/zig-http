const std = @import("std");
const utils = @import("zig_http").utils;
const middleware = @import("zig_http").middleware;
const net = @import("std").net;
const posix = @import("std").posix;

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
    const PARSED_ADDR = try std.net.Address.parseIp(ADDRESS, PORT);
    const allocator = std.heap.page_allocator;
    const listener = try posix.socket(PARSED_ADDR.any.family, TPE, PROTOCOL);
    defer posix.close(listener);
    try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(listener, &PARSED_ADDR.any, PARSED_ADDR.getOsSockLen());
    try posix.listen(listener, SIZE);
    var _req: [SIZE]u8 = undefined;
    var _res: [SIZE]u8 = undefined;
    std.debug.print("Test {f}\n", .{utils.HttpCode.OK});

    std.debug.print("Listening on {s}:{d}\n", .{ ADDRESS, PORT });
    while (true) {
        loop(allocator, listener, &_req, &_res);
    }
}

fn loop(allocator: std.mem.Allocator, listener: posix.socket_t, _req: *[SIZE]u8, _res: *[SIZE]u8) void {
    var client_address: net.Address = undefined;
    var client_address_len: posix.socklen_t = @sizeOf(net.Address);
    var response = utils.Response.init(_res);
    defer (&response).deinit();

    const socket = posix.accept(listener, &client_address.any, &client_address_len, 0) catch |err| {
        std.debug.print("error accept: {}\n", .{err});
        return;
    };
    defer posix.close(socket);

    const read = posix.read(socket, _req) catch |err| {
        std.debug.print("error reading: {}\n", .{err});
        return;
    };

    if (read == 0)
        return;

    var request = utils.Request.init(allocator, client_address, _req.*[0..read]) catch |err| {
        std.debug.print("Http message malformed: {}\n", .{err});

        return;
    };
    defer {
        (&request).deinit();
    }

    const route = std.meta.stringToEnum(Routes, request.route[1..]) orelse {
        routes.not_found(request, &response) catch return;
        utils.write_to_socket(socket, response.get_body()) catch |inner_err| {
            std.debug.print("error writing: {}\n", .{inner_err});
        };
        (&response).deinit();
        return;
    };

    switch (route) {
        .path => routes.path(request, &response) catch {
            return;
        },
        .echo => routes.echo(request, &response) catch {
            return;
        },
    }

    defer (&response).deinit();

    utils.write_to_socket(socket, response.get_body()) catch |err| {
        std.debug.print("error writing: {}\n", .{err});
    };

    return;
}

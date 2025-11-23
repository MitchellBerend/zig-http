const std = @import("std");
const net = @import("std").net;
const posix = @import("std").posix;

const utils = struct {
    const Request = @import("../../zig_http/utils/request.zig").Request;
    const Response = @import("../../zig_http/utils/response.zig").Response;
    const write_to_socket = @import("../../zig_http/utils/posix_socket_write.zig").write;
};

const TPE: u32 = posix.SOCK.STREAM;
const PROTOCOL = posix.IPPROTO.TCP;

pub fn Server(comptime size: u16) type {
    return struct {
        _listener: posix.socket_t,
        _req: *[size]u8,
        _res: *[size]u8,

        pub fn init(address: []const u8, port: u16, request_buffer: *[size]u8, response_buffer: *[size]u8) !@This() {
            const PARSED_ADDR = try std.net.Address.parseIp(address, port);
            const listener = try posix.socket(PARSED_ADDR.any.family, TPE, PROTOCOL);
            try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
            try posix.bind(listener, &PARSED_ADDR.any, PARSED_ADDR.getOsSockLen());
            try posix.listen(listener, size);
            return @This(){
                ._listener = listener,
                ._req = request_buffer,
                ._res = response_buffer,
            };
        }

        pub fn deinit(self: *@This()) void {
            posix.close(self._listener);
        }

        pub fn loop(self: *@This(), allocator: std.mem.Allocator, _loop: fn (std.mem.Allocator, utils.Request, *utils.Response) anyerror!void) !void {
            while (true) {
                var client_address: net.Address = undefined;
                var client_address_len: posix.socklen_t = @sizeOf(net.Address);
                var response = utils.Response.init(self._res);
                defer (&response).deinit();

                const socket = posix.accept(self._listener, &client_address.any, &client_address_len, 0) catch |err| {
                    std.debug.print("error accept: {}\n", .{err});
                    return;
                };
                defer posix.close(socket);

                const read = posix.read(socket, self._req) catch |err| {
                    std.debug.print("error reading: {}\n", .{err});
                    return;
                };

                if (read == 0)
                    return;

                var request = utils.Request.init(allocator, client_address, self._req.*[0..read]) catch |err| {
                    std.debug.print("Http message malformed: {}\n", .{err});

                    return;
                };
                defer {
                    (&request).deinit();
                }

                try _loop(allocator, request, &response);

                utils.write_to_socket(socket, (&response).get_body()) catch |err| {
                    std.debug.print("error writing: {}\n", .{err});
                };
            }
        }
    };
}

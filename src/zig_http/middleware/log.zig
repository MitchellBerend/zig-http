const std = @import("std");
const http_request = @import("../utils/request.zig");
const http_response = @import("../utils/response.zig");

pub const RouteHandlerFn = fn (
    req: http_request.Request,
    res: *http_response.Response,
) anyerror!void;

pub fn log(inner: RouteHandlerFn) RouteHandlerFn {
    return struct {
        pub fn wrapped(
            req: http_request.Request,
            res: *http_response.Response,
        ) anyerror!void {
            defer std.debug.print(
                "{f} [{f}] {f} {s}|{s}\n",
                .{
                    req.client_addr.in,
                    res._status,
                    req.method,
                    req.route,
                    res.get_body(),
                },
            );
            return try inner(req, res);
        }
    }.wrapped;
}

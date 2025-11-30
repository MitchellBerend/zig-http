const std = @import("std");

const http_methods = @import("find_method.zig");
const http_route = @import("find_route.zig");
const http_headers = @import("find_headers.zig");
const http_version = @import("find_http_version.zig");
const http_params = @import("find_params.zig");

pub const RequestError = error{ MethodNotFound, RouteNotFound, InvalidRoute, HttpVersionNotFound, HttpVersionMalformed, OutOfMemory, ParameterMalformed };

pub const Request = struct {
    client_addr: std.net.Address,
    method: http_methods.Method,
    route: []const u8,
    params: std.StringHashMap([]const u8),
    headers: std.StringHashMap([]const u8),
    version: http_version.HttpVersion,

    pub fn init(allocator: std.mem.Allocator, client_addr: std.net.Address, request: []const u8) RequestError!Request {
        const method = try http_methods.find_method(request);
        const route = try http_route.find_route(request);
        const params = try http_params.find_parameters(allocator, request);
        const headers = try http_headers.find_headers(allocator, request);
        const version = try http_version.find_http_version(request);

        return Request{
            .client_addr = client_addr,
            .method = method,
            .route = route,
            .params = params,
            .headers = headers,
            .version = version,
        };
    }

    pub fn deinit(self: *Request) void {
        self.headers.deinit();
    }
};

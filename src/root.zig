pub const utils = struct {
    const find_body_file = @import("zig_http/utils/find_body.zig");
    const headers_file = @import("zig_http/utils/find_headers.zig");
    const http_code_file = @import("zig_http/utils/http_codes.zig");
    const http_version_file = @import("zig_http/utils/find_http_version.zig");
    const http_request = @import("zig_http/utils/request.zig");
    const http_response = @import("zig_http/utils/response.zig");
    const method_file = @import("zig_http/utils/find_method.zig");
    const route_file = @import("zig_http/utils/find_route.zig");
    const posix_socket_write = @import("zig_http/utils/posix_socket_write.zig");

    pub const HttpVerion = http_version_file.HttpVersion;
    pub const Method = method_file.Method;
    pub const Request = http_request.Request;
    pub const Response = http_response.Response;

    pub const HttpVersionError = http_version_file.HttpVersionError;
    pub const MethodError = method_file.MethodError;
    pub const RouteError = route_file.RouteError;

    pub const HttpCode = http_code_file.HttpCode;

    pub const find_body = find_body_file.find_body;
    pub const find_http_version = http_version_file.find_http_version;
    pub const find_method = method_file.find_method;
    pub const find_route = route_file.find_route;
    pub const find_headres = headers_file.find_headers;
    pub const write_to_socket = posix_socket_write.write;
};

pub const routes = struct {
    const routes_mod = @import("zig_http/routes/mod.zig");

    pub const path = routes_mod.path;
    pub const echo = routes_mod.echo;
    pub const not_found = routes_mod.not_found;
};

pub const middleware = struct {
    const middleware_mod = @import("zig_http/middleware/mod.zig");

    pub const log = middleware_mod.@"log ";
};

pub const webserver = struct {
    const webserver_mod = @import("zig_http/webserver/mod.zig");

    pub const Server = webserver_mod.Server;
};

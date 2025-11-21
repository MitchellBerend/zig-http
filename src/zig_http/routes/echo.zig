const std = @import("std");
const http_request = @import("../utils/request.zig");
const http_response = @import("../utils/response.zig");
const http_method = @import("../utils/find_method.zig");
const HttpCode = @import("../utils/http_codes.zig").HttpCode;

const rv = "echo";

pub fn echo(req: http_request.Request, response: *http_response.Response) !void {
    if (req.method == http_method.Method.POST) {
        response.write_body(rv);
        response.write_status(HttpCode.OK);
    } else if (req.method == http_method.Method.OPTIONS) {
        response.write_body("");
        response.write_status(HttpCode.Continue);
    } else if (req.method == http_method.Method.GET) {
        response.write_body("");
        response.write_status(HttpCode.OK);
    } else {
        response.write_body("");
        response.write_status(HttpCode.MethodNotAllowed);
    }
}

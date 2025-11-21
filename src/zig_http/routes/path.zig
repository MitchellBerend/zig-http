const std = @import("std");
const http_request = @import("../utils/request.zig");
const http_response = @import("../utils/response.zig");
const HttpCode = @import("../utils/http_codes.zig").HttpCode;

const rv = "found something";

pub fn path(_: http_request.Request, response: *http_response.Response) !void {
    response.write_body(rv);
    response.write_status(HttpCode.OK);

    return;
}

const std = @import("std");
const http_request = @import("../utils/request.zig");
const http_response = @import("../utils/response.zig");
const HttpCode = @import("../utils/http_codes.zig").HttpCode;

pub fn not_found(_: http_request.Request, response: *http_response.Response) anyerror!void {
    response.write_status(HttpCode.NotFound);
    response.write_body("NotFound");
    return;
}

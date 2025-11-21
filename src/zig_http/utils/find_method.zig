const std = @import("std");

pub const Method = enum {
    GET,
    POST,
    PUT,
    PATCH,
    DELETE,
    HEAD,
    OPTIONS,

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) !void {
        return writer.writeAll(switch (self) {
            .GET => "GET",
            .POST => "POST",
            .PUT => "PUT",
            .PATCH => "PATCH",
            .DELETE => "DELETE",
            .HEAD => "HEAD",
            .OPTIONS => "OPTIONS",
        });
    }
};

pub const MethodError = error{NotFound};

pub fn find_method(request: []const u8) MethodError!Method {
    var return_method: Method = undefined;

    var lines = std.mem.splitScalar(u8, request, '\n');
    const first_line = lines.first();
    var words = std.mem.splitScalar(u8, first_line, ' ');
    const method = words.first();

    if (std.mem.eql(u8, method, "GET")) {
        return_method = Method.GET;
    } else if (std.mem.eql(u8, method, "POST")) {
        return_method = Method.POST;
    } else if (std.mem.eql(u8, method, "PUT")) {
        return_method = Method.PUT;
    } else if (std.mem.eql(u8, method, "PATCH")) {
        return_method = Method.PATCH;
    } else if (std.mem.eql(u8, method, "DELETE")) {
        return_method = Method.DELETE;
    } else if (std.mem.eql(u8, method, "HEAD")) {
        return_method = Method.HEAD;
    } else if (std.mem.eql(u8, method, "OPTIONS")) {
        return_method = Method.OPTIONS;
    } else {
        return MethodError.NotFound;
    }

    return return_method;
}

test "findGET" {
    const message =
        \\GET /index.html HTTP/1.1
        \\Host: www.example.com
        \\User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
        \\Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
        \\Accept-Language: en-US,en;q=0.5
        \\Accept-Encoding: gzip, deflate, br
        \\Connection: keep-alive
        \\Upgrade-Insecure-Requests: 1
    ;
    const result = try find_method(message);
    try std.testing.expectEqual(Method.GET, result);
}

test "find_method error" {
    const message =
        \\Connection: keep-alive
        \\Upgrade-Insecure-Requests: 1
    ;
    const result = find_method(message);
    try std.testing.expectError(MethodError.NotFound, result);
}

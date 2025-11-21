const std = @import("std");

pub const RouteError = error{ NotFound, InvalidRoute };

pub fn find_route(request: []const u8) RouteError![]const u8 {
    var route: []const u8 = undefined;

    var lines = std.mem.splitScalar(u8, request, '\n');
    const first_line = lines.first();
    var words = std.mem.splitScalar(u8, first_line, ' ');
    _ = words.first();
    const second = words.next();

    if (second == null) {
        return RouteError.NotFound;
    }
    route = second.?;

    if (!std.mem.startsWith(u8, route, "/")) {
        return RouteError.InvalidRoute;
    }

    return route;
}

test "find route" {
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
    const result = try find_route(message);
    try std.testing.expectEqualDeep("/index.html", result);
}

test "no route error" {
    const message =
        \\GET
    ;
    const result = find_route(message);
    try std.testing.expectError(RouteError.NotFound, result);
}

test "route malformed" {
    const message =
        \\GET index.html HTTP/1.1
    ;
    const result = find_route(message);
    try std.testing.expectError(RouteError.InvalidRoute, result);
}

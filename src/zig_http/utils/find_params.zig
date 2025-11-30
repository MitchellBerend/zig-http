const std = @import("std");

const ParameterError = error{ OutOfMemory, ParameterMalformed };

pub fn find_parameters(allocator: std.mem.Allocator, request: []const u8) ParameterError!std.StringHashMap([]const u8) {
    var parameters: std.StringHashMap([]const u8) = std.StringHashMap([]const u8).init(allocator);
    var lines = std.mem.splitScalar(u8, request, '\n');
    const first_line = lines.first();
    var words = std.mem.splitScalar(u8, first_line, ' ');
    _ = words.first();
    const second = words.next() orelse return parameters;
    var parts = std.mem.splitScalar(u8, second, '?');
    _ = parts.first();
    const unparsed_params = parts.next() orelse return parameters;
    var parameters_parts = std.mem.splitScalar(u8, unparsed_params, '&');

    while (parameters_parts.next()) |line| {
        if (!std.mem.containsAtLeast(u8, line, 1, "=")) {
            continue;
        }

        var key_value = std.mem.splitScalar(u8, line, '=');
        const key = key_value.first();
        const value: []const u8 = key_value.next() orelse return error.ParameterMalformed;
        try parameters.put(key, std.mem.trim(u8, value, " "));
    }

    return parameters;
}

test "find parameters" {
    const allocator = std.testing.allocator;
    const message =
        \\GET /index.html?filter=foo&mask=bar HTTP/1.1
        \\Host: www.example.com
        \\User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
        \\Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
        \\Accept-Language: en-US,en;q=0.5
        \\Accept-Encoding: gzip, deflate, br
        \\Connection: keep-alive
        \\Upgrade-Insecure-Requests: 1
    ;
    var params = try find_parameters(allocator, message);
    defer params.deinit();

    try std.testing.expectEqualDeep("foo", params.get("filter").?);
    try std.testing.expectEqualDeep("bar", params.get("mask").?);
}

test "find no parameters" {
    const allocator = std.testing.allocator;
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
    var counter: usize = 0;
    var params = try find_parameters(allocator, message);
    defer params.deinit();

    var iter = params.keyIterator();
    while (iter.next()) |_| {
        counter += 1;
    }

    try std.testing.expectEqual(0, counter);
}

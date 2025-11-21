const std = @import("std");

pub fn find_headers(allocator: std.mem.Allocator, request: []const u8) !std.StringHashMap([]const u8) {
    var headers: std.StringHashMap([]const u8) = std.StringHashMap([]const u8).init(allocator);
    var lines = std.mem.splitScalar(u8, request, '\n');
    _ = lines.first();

    while (lines.next()) |line| {
        if (!std.mem.containsAtLeast(u8, line, 1, ":")) {
            continue;
        }
        var words = std.mem.splitScalar(u8, line, ':');
        const key = words.first();
        const value: []const u8 = words.next() orelse continue;
        try headers.put(key, std.mem.trim(u8, value, " "));
    }

    return headers;
}

test "find headers" {
    const allocator = std.testing.allocator;
    const message =
        \\GET /index.html HTTP/1.1
        \\Host: www.example.com
        \\Connection: keep-alive
        \\Upgrade-Insecure-Requests: 1
    ;
    var headers = try find_headers(allocator, message);
    defer headers.deinit();

    try std.testing.expectEqualStrings("www.example.com", headers.get("Host").?);
    try std.testing.expectEqualStrings("keep-alive", headers.get("Connection").?);
    try std.testing.expectEqualStrings("1", headers.get("Upgrade-Insecure-Requests").?);
}

test "missing colon" {
    const allocator = std.testing.allocator;
    const message =
        \\GET /home HTTP/1.1
        \\Host example.com
        \\User-Agent: TestClient/1.0
    ;
    var headers = try find_headers(allocator, message);
    try std.testing.expectEqualStrings("TestClient/1.0", headers.get("User-Agent").?);
    try std.testing.expectEqual(null, headers.get("Host"));
    defer headers.deinit();
}

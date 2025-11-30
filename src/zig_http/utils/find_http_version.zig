const std = @import("std");

pub const HttpVersion = enum {
    HTTP09,
    HTTP10,
    HTTP11,

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        switch (self) {
            HttpVersion.HTTP09 => try writer.print("HTTP/0.9", .{}),
            HttpVersion.HTTP10 => try writer.print("HTTP/1.0", .{}),
            HttpVersion.HTTP11 => try writer.print("HTTP/1.1", .{}),
        }
    }
};

pub const HttpVersionError = error{ HttpVersionNotFound, HttpVersionMalformed };

pub fn find_http_version(request: []const u8) HttpVersionError!HttpVersion {
    var version: HttpVersion = undefined;

    var lines = std.mem.splitAny(u8, request, &[_]u8{ 13, 10 });
    const first_line = lines.first();

    var words = std.mem.splitScalar(u8, first_line, ' ');

    _ = words.first();
    _ = words.next() orelse return HttpVersionError.HttpVersionMalformed;
    const _version = words.next() orelse return HttpVersionError.HttpVersionMalformed;

    if (std.mem.eql(u8, _version, "HTTP/0.9")) {
        version = HttpVersion.HTTP09;
    } else if (std.mem.eql(u8, _version, "HTTP/1.0")) {
        version = HttpVersion.HTTP10;
    } else if (std.mem.eql(u8, _version, "HTTP/1.1")) {
        version = HttpVersion.HTTP11;
    } else {
        return HttpVersionError.HttpVersionNotFound;
    }

    return version;
}

test "Find correct version" {
    const request =
        \\GET /index.html HTTP/1.1
        \\Host: www.example.com
        \\User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
        \\Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
        \\Accept-Language: en-US,en;q=0.5
        \\Accept-Encoding: gzip, deflate, br
        \\Connection: keep-alive
        \\Upgrade-Insecure-Requests: 1
    ;
    const version = try find_http_version(request);

    try std.testing.expectEqual(HttpVersion.HTTP11, version);
}

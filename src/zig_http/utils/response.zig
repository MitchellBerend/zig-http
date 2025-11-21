const std = @import("std");
const StatusCode = @import("http_codes.zig").HttpCode;
const HttpVersion = @import("find_http_version.zig").HttpVersion;

pub const Response = struct {
    _status: StatusCode,
    _version: HttpVersion,
    _buffer: *[1024]u8,
    _buffer_len: usize,

    pub fn init(buffer: *[1024]u8) @This() {
        return @This(){ ._status = undefined, ._version = undefined, ._buffer = buffer, ._buffer_len = 0 };
    }

    pub fn deinit(self: *@This()) void {
        @memset(self._buffer[0..], 0);
        self._buffer_len = 0;
        return;
    }

    pub fn write_status(self: *@This(), status: StatusCode) void {
        self._status = status;
        return;
    }

    pub fn write_body(self: *@This(), body: []const u8) void {
        self._buffer_len = body.len;
        @memcpy(self._buffer[3 .. self._buffer_len + 3], body);
        return;
    }

    pub fn get_body(self: *@This()) []const u8 {
        return self._buffer[3 .. self._buffer_len + 3];
    }

    pub fn get_status(self: *@This()) [3]u8 {
        return (self._buffer[0..3].*);
    }
};

// pub fn Response(size: u16) type {
//     return struct {
//         _status: StatusCode,
//         _version: HttpVersion,
//         _buffer: *[size]u8,
//         _buffer_len: usize,
//
//         pub fn init(buffer: *[size]u8) @This() {
//             return @This(){ ._status = undefined, ._version = undefined, ._buffer = buffer, ._buffer_len = 0 };
//         }
//
//         pub fn deinit(self: *@This()) void {
//             @memset(self._buffer[0..], 0);
//             self._buffer_len = 0;
//             return;
//         }
//
//         pub fn write_status(self: *@This(), status: StatusCode) void {
//             self._status = status;
//             return;
//         }
//
//         pub fn write_body(self: *@This(), body: []const u8) void {
//             self._buffer_len = body.len;
//             @memcpy(self._buffer[3 .. self._buffer_len + 3], body);
//             return;
//         }
//
//         pub fn get_body(self: *@This()) []const u8 {
//             return self._buffer[3 .. self._buffer_len + 3];
//         }
//
//         pub fn get_status(self: *@This()) [3]u8 {
//             return (self._buffer[0..3].*);
//         }
//     };
// }

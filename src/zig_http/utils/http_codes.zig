const std = @import("std");

pub const HttpCode = enum {
    Continue,
    OK,
    BadRequest,
    NotFound,
    MethodNotAllowed,

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        switch (self) {
            HttpCode.Continue => try writer.print("100 Continue", .{}),
            HttpCode.OK => try writer.print("200 OK", .{}),
            HttpCode.BadRequest => try writer.print("400 Bad Request", .{}),
            HttpCode.NotFound => try writer.print("404 Not Found", .{}),
            HttpCode.MethodNotAllowed => try writer.print("405 Method Not Allowed", .{}),
        }
    }
};

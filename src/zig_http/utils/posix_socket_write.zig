const posix = @import("std").posix;

pub fn write(socket: posix.socket_t, msg: []const u8) !void {
    var pos: usize = 0;
    while (pos < msg.len) {
        const written = try posix.write(socket, msg[pos..]);
        if (written == 0)
            return error.Closed;
        pos += written;
    }
}

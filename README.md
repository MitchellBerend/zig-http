# Why?

This project is just me experimenting with zig. I choose to implement an http
server because I was working on some middleware during my day job. Currently the
server can accept a tcp message sent to it via [socat](https://linux.die.net/man/1/socat). I also implemented a log
middleware that checks the incoming request and subsequent response and logs the
source address, route and status code.

The only heap allocations that happen are for parsing the headers. Everything
else is written to a predefined buffer. The initial implementation had a Request
struct that was generic over it's buffer size. I could not figure out how to
generate a type in comptime that returned a included the size information when
implementing my middleware.

Not sure what happens when a request is larger than 1024 bytes. A log line gets
printed but socat shows this:

```bash
2025/11/21 19:10:48 socat[57016] E read(5, 0x733000000, 8192): Connection reset by peer
```

# Good to know

- Zig 0.15.2
- Only tested on Arm
- `dos.sh` let's you send "random" requests to the server.

const std = @import("std");

const usageText =
    \\Zigox - A Zig-based dotfile manager
    \\
    \\Usage:
    \\  zigox apply [profile]     Apply configuration for a profile (default: default)
    \\  zigox status [profile]    Show status of managed files
    \\  zigox clean [profile]     Remove managed symlinks
    \\  zigox list-profiles       List available profiles
    \\  zigox help                Show this help message
    \\
    \\Options:
    \\  -h, --help                 Show this help message
    \\  -v, --verbose              Enable verbose logging
    \\  --repo-path=PATH           Path to dotfiles repository
;

pub fn main() !void {
    printUsage();
}

fn printUsage() void {
    std.debug.print("{s}\n", .{usageText});
}

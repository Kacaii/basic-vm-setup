const builtin = @import("builtin");
const std = @import("std");

const Homebrew = @import("./steps/homebrew.zig");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator, const is_debug = switch (builtin.mode) {
        .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
        .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
    };

    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };

    const root_node = std.Progress.start(.{
        .root_name = "Setting up your new virtual machine! ✨",
    });
    defer root_node.end();

    // Install required formulaes 
    var homebrew_thread = try std.Thread.spawn(
        .{ .allocator = allocator },
        Homebrew.init,
        .{ allocator, root_node },
    );

    defer {
        homebrew_thread.join();
    }
}

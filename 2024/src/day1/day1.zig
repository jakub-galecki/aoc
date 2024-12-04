const std = @import("std");

test "solution" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    const file = try std.fs.cwd().openFile("in.txt", .{});
    defer file.close();

    var r = file.reader();

    var arr1: [1000]i32 = undefined;
    var arr2: [1000]i32 = undefined;

    var buf: [1024]u8 = undefined;
    var i: usize = 0;

    while (try r.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splitted = std.mem.splitSequence(u8, line, ",");
        arr1[i] = try std.fmt.parseInt(i32, splitted.first(), 10);
        const next = splitted.next().?;
        arr2[i] = try std.fmt.parseInt(i32, next, 10);
        i += 1;
    }
    std.debug.assert(i == 1000);
    std.mem.sort(i32, &arr1, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, &arr2, {}, comptime std.sort.asc(i32));

    var diff_sum: i64 = 0;
    for (arr1, 0..) |_, idx| {
        const diff = arr1[idx] - arr2[idx];
        diff_sum += @abs(diff);
    }
    std.debug.print("diff_sum: {}\n", .{diff_sum});

    // could also use set

    var seen = std.AutoHashMap(i32, bool).init(allocator);
    defer seen.deinit();

    var sim: i64 = 0;
    for (arr1) |value| {
        if (!seen.contains(value)) {
            const count: i32 = @intCast(std.mem.count(i32, &arr2, &[_]i32{value}));
            sim += value * count;
        }
        try seen.put(value, true);
    }
    std.debug.print("similarity {}\n", .{sim});
}

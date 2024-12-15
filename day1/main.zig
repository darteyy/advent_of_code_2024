const std = @import("std");
const sort = std.mem.sort;
const print = std.debug.print;
const assert = std.debug.assert;

pub fn main() !void {
    print("{d}\n", .{try partOne()});
}

fn partOne() !usize {
    const file = try std.fs.cwd().openFile(
        "input.txt",
        .{},
    );
    defer file.close();
    const filesize = try file.getEndPos();

    assert(filesize > 0);

    try file.seekTo(0);

    const alloc = std.heap.page_allocator;
    const contentBuffer = try file.reader().readAllAlloc(
        alloc,
        filesize,
    );
    defer alloc.free(contentBuffer);

    var leftNums = std.ArrayList(usize).init(alloc);
    defer leftNums.deinit();

    var rightNums = std.ArrayList(usize).init(alloc);
    defer rightNums.deinit();

    var lines = std.mem.splitSequence(u8, contentBuffer, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
                continue;
        }

        var nums = std.mem.splitSequence(u8, line, &[_]u8{ 32 } ** 3);
        if (nums.next()) |left_str| {
            const leftNum = try std.fmt.parseUnsigned(usize, left_str, 10);
            try leftNums.append(leftNum);
        } else {
            continue;
        }

        if (nums.next()) |right_str| {
            const rightNum = try std.fmt.parseUnsigned(usize, right_str, 10);
            try rightNums.append(rightNum);
        }
    }

    assert(leftNums.items.len == rightNums.items.len);

    sort(usize, leftNums.items, {}, comptime std.sort.desc(usize));
    sort(usize, rightNums.items, {}, comptime std.sort.desc(usize));

    var distance: usize = 0;
    for (0..leftNums.items.len) |_| {
        const leftNum = leftNums.pop();
        const rightNum = rightNums.pop();

        if (leftNum > rightNum) {
            distance += leftNum - rightNum;
        } else {
            distance += rightNum - leftNum;
        }
    }


    return distance;
}


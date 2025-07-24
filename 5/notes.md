# Notes about day 5


## Guessing the solution
My initial thinking after looking at the problem is that the solution could be
a binary tree
```zig
const PageNode = struct {
    value: u8,

    .before: ?*PageNode,
    .after: ?*PageNode,
};
```

The tricky part is that we will need to frequently update this tree as soon as
we detected a change of order to apply.

We could, maybe, also only rely on a simple list. But this would also need
frequent ordering.

Let's try manually ordering some nodes to have a small grasp about the possible
solution

47|53 .
97|13 .. 
97|61 ...
97|47 ....
75|29 .....
61|13 ......
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

47<53
47<53, 97<13
47<53, 97<13, 97<61
97<13, 97<61, 97<47, 47<53
97<13, 97<61, 97<47, 47<53, 75<29
97<61<13, 97<47<53, 75<29







## TODO

- [x] parse input
  => naive implem done, works. Maybe there's a cleaner solution but I think that it's really alright for the moment.

- [x] process rules to produce tree or list
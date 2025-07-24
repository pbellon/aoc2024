# Advent of Code 2024

This repository contains the code to solve the advent of code 2024. This year I wanted to do it in
zig in order to learn more about this language.

## Prequisites
You must have [zig][download-zig] in order to run the various days of the advent of code.

## How to run?

You can run a specific day with `zig run <day>/main.zig` or you can run all of them with
`zig run all.zig` but please note day 6 is poorly optimized and can run for several seconds or even
minutes. For that reason it's advised to compile with `zig build-exe -O ReleaseFast all.zig` or
`zig build-exe -O ReleaseFast 6/main.zig`.


[download-zig]: https://ziglang.org/download/
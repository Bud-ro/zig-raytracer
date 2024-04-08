# Zig Raytracer

This repo shows my attempts at following the [Ray Tracing in One Weekend](https://raytracing.github.io/) series of books, rewriting the code in Zig. 

![Ray Tracing In One Weekend](./rt_in_one_weekend.png)

## Instructions

Clone the repo, then run `zig build run > image.ppm` to generate the image. Use of the `-Doptimize=ReleaseFast` flag is recommended for significantly faster render times. Use an online PPM viewer or download one in order to view the image.
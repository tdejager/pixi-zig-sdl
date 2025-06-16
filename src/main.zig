const std = @import("std");
const sdl = @import("zig_sdl_lib");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const SCREEN_WIDTH = 1200;
const SCREEN_HEIGHT = 800;

pub fn main() !void {
    // Initialize SDL3
    try sdl.init(.{ .video = true });
    defer sdl.quit();

    // Create window
    const window = try sdl.createWindow("SDL3 Zig Example from pixi!", SCREEN_WIDTH, SCREEN_HEIGHT, .{ .resizable = true });
    defer sdl.destroyWindow(window);

    // Create renderer
    const renderer = try sdl.createRenderer(window);
    defer sdl.destroyRenderer(renderer);

    std.log.info("SDL3 initialized successfully!", .{});
    std.log.info("Window created: {}x{}", .{ SCREEN_WIDTH, SCREEN_HEIGHT });
    std.log.info("Press ESC or close window to exit", .{});

    // Main loop
    var running = true;

    while (running) {
        // Handle events
        while (sdl.pollEvent()) |event| {
            switch (event.type) {
                c.SDL_EVENT_QUIT => {
                    running = false;
                },
                c.SDL_EVENT_KEY_DOWN => {
                    if (event.key.key == c.SDLK_ESCAPE) {
                        running = false;
                    }
                },
                else => {},
            }
        }

        // Clear screen with blue color
        sdl.setRenderDrawColor(renderer, .{ .r = 30, .g = 100, .b = 200 });
        sdl.renderClear(renderer);

        // Draw a simple rectangle using the wrapper
        const rect = sdl.Rect{
            .x = @as(f32, @floatFromInt(SCREEN_WIDTH)) / 2 - 50,
            .y = @as(f32, @floatFromInt(SCREEN_HEIGHT)) / 2 - 50,
            .w = 100,
            .h = 100,
        };

        sdl.setRenderDrawColor(renderer, sdl.Color.WHITE);
        sdl.renderFillRect(renderer, rect);

        // Present the frame
        sdl.renderPresent(renderer);

        // Small delay to prevent excessive CPU usage
        sdl.delay(16); // ~60 FPS
    }

    std.log.info("Shutting down SDL3...", .{});
}

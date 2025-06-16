//! SDL3 utilities and helper functions for Zig
//! This module provides Zig-friendly wrappers around SDL3 C functions

const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

/// SDL3 initialization flags
pub const InitFlags = struct {
    video: bool = false,
    audio: bool = false,
    gamepad: bool = false,
    joystick: bool = false,
    haptic: bool = false,
    sensor: bool = false,
    events: bool = false,

    pub fn toSDLFlags(self: InitFlags) u32 {
        var flags: u32 = 0;
        if (self.video) flags |= c.SDL_INIT_VIDEO;
        if (self.audio) flags |= c.SDL_INIT_AUDIO;
        if (self.gamepad) flags |= c.SDL_INIT_GAMEPAD;
        if (self.joystick) flags |= c.SDL_INIT_JOYSTICK;
        if (self.haptic) flags |= c.SDL_INIT_HAPTIC;
        if (self.sensor) flags |= c.SDL_INIT_SENSOR;
        if (self.events) flags |= c.SDL_INIT_EVENTS;
        return flags;
    }
};

/// SDL3 Error type
pub const SDLError = error{
    InitializationFailed,
    WindowCreationFailed,
    RendererCreationFailed,
    SurfaceCreationFailed,
    Unknown,
};

/// Get the last SDL error as a Zig string
pub fn getError() []const u8 {
    const err_ptr = c.SDL_GetError();
    if (err_ptr == null) return "Unknown SDL error";
    return std.mem.span(err_ptr);
}

/// Initialize SDL3 with the specified subsystems
pub fn init(flags: InitFlags) SDLError!void {
    if (!c.SDL_Init(flags.toSDLFlags())) {
        std.log.err("SDL_Init failed: {s}", .{getError()});
        return SDLError.InitializationFailed;
    }
}

/// Quit SDL3 and clean up all subsystems
pub fn quit() void {
    c.SDL_Quit();
}

/// Window creation options
pub const WindowOptions = struct {
    resizable: bool = false,
    fullscreen: bool = false,
    borderless: bool = false,
    always_on_top: bool = false,
    high_pixel_density: bool = false,

    pub fn toSDLFlags(self: WindowOptions) u32 {
        var flags: u32 = 0;
        if (self.resizable) flags |= c.SDL_WINDOW_RESIZABLE;
        if (self.fullscreen) flags |= c.SDL_WINDOW_FULLSCREEN;
        if (self.borderless) flags |= c.SDL_WINDOW_BORDERLESS;
        if (self.always_on_top) flags |= c.SDL_WINDOW_ALWAYS_ON_TOP;
        if (self.high_pixel_density) flags |= c.SDL_WINDOW_HIGH_PIXEL_DENSITY;
        return flags;
    }
};

/// Create a new SDL3 window
pub fn createWindow(title: [:0]const u8, width: i32, height: i32, options: WindowOptions) SDLError!*c.SDL_Window {
    const window = c.SDL_CreateWindow(title, width, height, options.toSDLFlags());
    if (window == null) {
        std.log.err("SDL_CreateWindow failed: {s}", .{getError()});
        return SDLError.WindowCreationFailed;
    }
    return window.?;
}

/// Destroy an SDL3 window
pub fn destroyWindow(window: *c.SDL_Window) void {
    c.SDL_DestroyWindow(window);
}

/// Renderer creation options
pub const RendererOptions = struct {
    accelerated: bool = true,
    vsync: bool = false,

    pub fn toSDLFlags(self: RendererOptions) u32 {
        var flags: u32 = 0;
        if (self.accelerated) flags |= c.SDL_RENDERER_ACCELERATED;
        if (self.vsync) flags |= c.SDL_RENDERER_PRESENTVSYNC;
        return flags;
    }
};

/// Create a new SDL3 renderer
pub fn createRenderer(window: *c.SDL_Window) SDLError!*c.SDL_Renderer {
    const renderer = c.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.log.err("SDL_CreateRenderer failed: {s}", .{getError()});
        return SDLError.RendererCreationFailed;
    }
    return renderer.?;
}

/// Destroy an SDL3 renderer
pub fn destroyRenderer(renderer: *c.SDL_Renderer) void {
    c.SDL_DestroyRenderer(renderer);
}

/// Color structure
pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,

    pub const BLACK = Color{ .r = 0, .g = 0, .b = 0 };
    pub const WHITE = Color{ .r = 255, .g = 255, .b = 255 };
    pub const RED = Color{ .r = 255, .g = 0, .b = 0 };
    pub const GREEN = Color{ .r = 0, .g = 255, .b = 0 };
    pub const BLUE = Color{ .r = 0, .g = 0, .b = 255 };
    pub const YELLOW = Color{ .r = 255, .g = 255, .b = 0 };
    pub const CYAN = Color{ .r = 0, .g = 255, .b = 255 };
    pub const MAGENTA = Color{ .r = 255, .g = 0, .b = 255 };
};

/// Set the renderer draw color
pub fn setRenderDrawColor(renderer: *c.SDL_Renderer, color: Color) void {
    _ = c.SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
}

/// Clear the renderer with the current draw color
pub fn renderClear(renderer: *c.SDL_Renderer) void {
    _ = c.SDL_RenderClear(renderer);
}

/// Present the current frame
pub fn renderPresent(renderer: *c.SDL_Renderer) void {
    _ = c.SDL_RenderPresent(renderer);
}

/// Rectangle structure
pub const Rect = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn toSDLRect(self: Rect) c.SDL_FRect {
        return c.SDL_FRect{
            .x = self.x,
            .y = self.y,
            .w = self.w,
            .h = self.h,
        };
    }
};

/// Fill a rectangle with the current draw color
pub fn renderFillRect(renderer: *c.SDL_Renderer, rect: Rect) void {
    var sdl_rect = rect.toSDLRect();
    _ = c.SDL_RenderFillRect(renderer, &sdl_rect);
}

/// Draw a rectangle outline with the current draw color
pub fn renderDrawRect(renderer: *c.SDL_Renderer, rect: Rect) void {
    var sdl_rect = rect.toSDLRect();
    _ = c.SDL_RenderRect(renderer, &sdl_rect);
}

/// Draw a line with the current draw color
pub fn renderDrawLine(renderer: *c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32) void {
    _ = c.SDL_RenderLine(renderer, x1, y1, x2, y2);
}

/// Draw a point with the current draw color
pub fn renderDrawPoint(renderer: *c.SDL_Renderer, x: f32, y: f32) void {
    _ = c.SDL_RenderPoint(renderer, x, y);
}

/// Poll for events
pub fn pollEvent() ?c.SDL_Event {
    var event: c.SDL_Event = undefined;
    if (c.SDL_PollEvent(&event)) {
        return event;
    }
    return null;
}

/// Wait for an event
pub fn waitEvent() ?c.SDL_Event {
    var event: c.SDL_Event = undefined;
    if (c.SDL_WaitEvent(&event)) {
        return event;
    }
    return null;
}

/// Delay execution for the specified number of milliseconds
pub fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}

/// Get the current tick count in milliseconds
pub fn getTicks() u64 {
    return c.SDL_GetTicks();
}

/// Get window size
pub fn getWindowSize(window: *c.SDL_Window) struct { width: i32, height: i32 } {
    var width: i32 = undefined;
    var height: i32 = undefined;
    _ = c.SDL_GetWindowSize(window, &width, &height);
    return .{ .width = width, .height = height };
}

/// Set window size
pub fn setWindowSize(window: *c.SDL_Window, width: i32, height: i32) void {
    _ = c.SDL_SetWindowSize(window, width, height);
}

/// Get window position
pub fn getWindowPosition(window: *c.SDL_Window) struct { x: i32, y: i32 } {
    var x: i32 = undefined;
    var y: i32 = undefined;
    _ = c.SDL_GetWindowPosition(window, &x, &y);
    return .{ .x = x, .y = y };
}

/// Set window position
pub fn setWindowPosition(window: *c.SDL_Window, x: i32, y: i32) void {
    _ = c.SDL_SetWindowPosition(window, x, y);
}

// Tests
test "InitFlags conversion" {
    const flags = InitFlags{ .video = true, .audio = true };
    const sdl_flags = flags.toSDLFlags();
    try testing.expect((sdl_flags & c.SDL_INIT_VIDEO) != 0);
    try testing.expect((sdl_flags & c.SDL_INIT_AUDIO) != 0);
    try testing.expect((sdl_flags & c.SDL_INIT_GAMEPAD) == 0);
}

test "WindowOptions conversion" {
    const options = WindowOptions{ .resizable = true, .fullscreen = false };
    const sdl_flags = options.toSDLFlags();
    try testing.expect((sdl_flags & c.SDL_WINDOW_RESIZABLE) != 0);
    try testing.expect((sdl_flags & c.SDL_WINDOW_FULLSCREEN) == 0);
}

test "Color constants" {
    try testing.expect(Color.BLACK.r == 0);
    try testing.expect(Color.WHITE.r == 255);
    try testing.expect(Color.RED.g == 0);
    try testing.expect(Color.GREEN.g == 255);
}

test "Rect conversion" {
    const rect = Rect{ .x = 10, .y = 20, .w = 100, .h = 200 };
    const sdl_rect = rect.toSDLRect();
    try testing.expect(sdl_rect.x == 10);
    try testing.expect(sdl_rect.y == 20);
    try testing.expect(sdl_rect.w == 100);
    try testing.expect(sdl_rect.h == 200);
}

test "basic functionality" {
    // Test that we can create the basic structures
    const init_flags = InitFlags{ .video = true };
    try testing.expect(init_flags.video == true);

    const window_opts = WindowOptions{ .resizable = true };
    try testing.expect(window_opts.resizable == true);

    const color = Color{ .r = 128, .g = 64, .b = 32 };
    try testing.expect(color.r == 128);
    try testing.expect(color.a == 255); // default alpha
}

# Zig SDL3 Showcase

A graphics application demonstrating **Zig + SDL3** integration with **Pixi** package management for cross-platform development.

![Zig](https://img.shields.io/badge/Zig-0.14.0-orange?style=flat-square&logo=zig)
![SDL3](https://img.shields.io/badge/SDL3-3.2.16-blue?style=flat-square)

## 🚀 What This Showcases

This project demonstrates the combination of:

- **Zig 0.14+** - Modern systems programming language
- **SDL3** - Latest version of the Simple DirectMedia Layer
- **Pixi** - Fast, cross-platform package manager
- **Task system** - For simple automation

## 🏃 Quick Start

### Prerequisites

- [Pixi](https://pixi.sh) package manager
- That's it! Pixi handles Zig and SDL3 installation

### Run the Demo

```bash
# Clone and enter the project
git clone <your-repo>
cd zig-sdl

# Install dependencies and run (one command!) should work anywhere
pixi run start
```

The application will open a window displaying a white rectangle on a blue background. Press `ESC` or close the window to exit.

### Development Commands

```bash
# Build only
pixi run build

# Run tests
pixi run test

# Invoke zig directly
pixi run zig <cmd>

# Launch IDE in pixi for completions
pixi r zed
pixi r code
```

### Dependencies

- **Zig 0.14.0+**: Modern systems language with excellent C interop
- **SDL3 3.2.16+**: Latest SDL with improved APIs and performance
- **Pixi**: Conda-based package manager for reproducible environments

### Supported Platforms

Currently configured for:
- macOS ARM64 (Apple Silicon)
- Linux x86_64
- Windows x86_64
Just add more platforms in `pixi.toml` as needed.

### Pixi Power?
- **Reproducible environments** across machines
- **Fast dependency resolution** via conda-forge
- **No system pollution** - everything in project scope
- **Simple configuration** with powerful features

## 📚 Learn More

- [Pixi Documentation](https://pixi.sh/docs/)
- [Zig Language Reference](https://ziglang.org/documentation/)
- [SDL3 Documentation](https://wiki.libsdl.org/SDL3/)

## 🤝 Contributing

This project serves as a template and learning resource. Feel free to:

- Fork and modify for your own projects
- Submit improvements to the SDL3 wrappers
- Add support for more platforms
- Extend with additional SDL3 features

---

**Happy coding with Zig + SDL3 + Pixi!** 🎉


# Native debug build
build:
    cargo build

# Native release build
release:
    cargo build --release

# Cross-compile for ARM64 musl (OpenWrt / embedded)
build-aarch64-musl:
    cargo zigbuild --target aarch64-unknown-linux-musl --release

# Cross-compile for x86_64 musl (static Linux binary)
build-x86_64-musl:
    cargo zigbuild --target x86_64-unknown-linux-musl --release

# Cross-compile for ARM64 GNU (Linux ARM64)
build-aarch64-gnu:
    cargo zigbuild --target aarch64-unknown-linux-gnu --release

# Cross-compile for Windows x86_64
build-windows:
    cargo zigbuild --target x86_64-pc-windows-gnu --release

# Build all cross-compile targets
build-all: build-aarch64-musl build-x86_64-musl build-aarch64-gnu build-windows

# Run tests
test:
    cargo test

# Check formatting
fmt:
    cargo fmt -- --check

# Lint
clippy:
    cargo clippy

# Clean build artifacts
clean:
    cargo clean
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

cygnus-rs is a cross-platform JLU Drcom client — a campus network authentication tool for Jilin University. It implements the Drcom protocol over UDP to authenticate and maintain a network connection.

## Build & Run Commands

```shell
cargo build                  # Debug build
cargo build --release        # Release build
cargo run -- --help          # Run with help
cargo test                   # Run all tests (currently only user/cipher.encrypt_decrypt)
cargo fmt -- --check         # Check formatting (max_width=80, tab_spaces=4)
cargo clippy                 # Lint
```

Cross-compilation uses `just` and `cargo-zigbuild`:
```shell
just build-aarch64-musl    # ARM64 musl (OpenWrt / embedded)
just build-x86_64-musl     # x86_64 musl (static Linux binary)
just build-aarch64-gnu     # ARM64 GNU (Linux ARM64)
just build-windows         # Windows x86_64
just build-all             # All cross-compile targets
```

CLI usage:
```shell
cygnus user create -u <username> -p <password> -m <mac_addr> -f cygnus.usr   # Create encrypted credential file
cygnus user inspect -f cygnus.usr                                             # Inspect credential file
cygnus auth -f cygnus.usr                                                     # Authenticate (infinite retry by default)
cygnus auth -f cygnus.usr -r 3 -d 1000                                        # Retry 3 times, 1000ms delay
```

MAC address uses colon separators (e.g. `aa:bb:cc:dd:ee:ff`).

## Architecture

The binary is `src/main.rs` → `src/lib.rs` with three modules:

- **`args`** — CLI argument structs using `clap` derive macros. Two top-level subcommands: `Auth` and `User`.
- **`user`** — Manages encrypted credential files. `User` struct holds username, password, and MAC. `UserCipher` encrypts/decrypts using AES-256-GCM with a random key+nonce stored in-band. The `.usr` file format is: `[32-byte key][12-byte nonce][8-byte len][encrypted_password][8-byte len][username][6-byte mac]`.
- **`auth`** — Implements the Drcom protocol. `DrContext` holds a `UdpSocket` connected to `10.100.61.3:61440`, runtime `DrContextData` (salt, client IP, md5a, tails), and the `User`. The auth flow is: `challenge` (5 retries) → `login` → `keep_alive` (infinite loop, 20s interval). Packet construction lives in `DrContext` methods; crypto helpers (`ror`, `checksum`, `crc`) are private functions in `context.rs`.

Error handling uses `thiserror` with two error enums: `AuthError` (wraps `std::io::Error` and `UserError`) and `UserError` (wraps `io::Error`, `aead::Error`, `FromUtf8Error`, `ParseIntError`).

## Key Dependencies

- `clap` — CLI argument parsing (derive)
- `aes-gcm` — AES-256-GCM encryption for credential files
- `md5` — MD5 hashing in Drcom protocol packets
- `tracing` / `tracing-subscriber` — structured logging with local timezone offsets
- `thiserror` — error derive macros
# NsJail C++ Sandbox Guide

A complete guide and toolkit for setting up and using NsJail to run C++ programs in isolated containers (see (nsjail.dev){nsjail.dev}).

## What This Is

This repository contains:
- **Setup guides** - Complete documentation for getting started with NsJail
- **Configuration files** - Ready-to-use sandbox configs
- **Helper scripts** - Convenience wrappers for running sandboxed programs
- **Examples** - Sample C++ programs demonstrating sandbox features

This is **not** a fork of NsJail itself - it's a companion guide to help you use NsJail effectively.

## Prerequisites

You need to install NsJail separately. Choose one method:

### Method 1: Build from Source
```bash
# Install dependencies (Debian/Ubuntu)
sudo apt-get install -y autoconf bison flex gcc g++ git \
    libprotobuf-dev libnl-route-3-dev libtool make pkg-config protobuf-compiler

# Clone and build NsJail
git clone https://github.com/google/nsjail.git
cd nsjail
make

# Optionally install system-wide
sudo cp nsjail /usr/local/bin/
```

### Method 2: Docker
```bash
docker pull ghcr.io/google/nsjail
```

## Quick Setup

1. **Clone this guide repository**:
```bash
git clone https://github.com/YOUR_USERNAME/nsjail-cpp-guide.git
cd nsjail-cpp-guide
```

2. **Install NsJail** (see Prerequisites above)

3. **Update script to point to your NsJail binary**:
If you installed NsJail to a custom location, edit `scripts/run_sandbox.sh` and set:
```bash
NSJAIL_BIN="/path/to/your/nsjail"
```

4. **Test the setup**:
```bash
make
make run
```

## What You Get

- ✅ **Secure sandboxing** - Process, network, and filesystem isolation
- ✅ **Resource limits** - CPU, memory, and time constraints
- ✅ **Easy testing** - Run competitive programming solutions safely
- ✅ **Batch testing** - Test multiple cases automatically
- ✅ **Well documented** - Complete guides and examples

## Documentation

- [QUICKSTART.md](docs/QUICKSTART.md) - Quick reference guide
- [SETUP_COMPLETE.md](docs/SETUP_COMPLETE.md) - Detailed examples and use cases
- [README_DETAILED.md](docs/README_DETAILED.md) - Advanced configuration and troubleshooting

## Usage Examples

### Run a Program in Sandbox
```bash
# Compile your program
g++ -o solution solution.cpp -std=c++11

# Run in sandbox
./scripts/run_sandbox.sh -p ./solution
```

### Batch Testing
```bash
# Test against multiple inputs
./scripts/batch_test.sh ./solution ./test_cases
```

### Custom Configuration
```bash
# Use advanced config with stricter limits
./scripts/run_sandbox.sh -c config/sandbox.cfg -p ./solution
```

## Files Included

| Directory/File | Description |
|------|-------------|
| `scripts/` | Helper scripts for running programs |
| `scripts/run_sandbox.sh` | Main wrapper script for running programs |
| `scripts/batch_test.sh` | Batch testing utility |
| `config/` | Sandbox configuration files |
| `config/simple-sandbox.cfg` | Basic sandbox configuration |
| `config/sandbox.cfg` | Advanced configuration with stricter limits |
| `examples/` | Example C++ programs |
| `docs/` | Complete guides and references |
| `Makefile` | Build automation |

## Security Features

Your programs run with:
- **Process isolation** - Separate PID namespace
- **Network isolation** - No network access
- **User isolation** - Non-privileged user (UID 99999)
- **Filesystem protection** - Read-only root filesystem
- **Resource limits** - Configurable CPU, memory, time limits
- **Mount namespace** - Isolated filesystem view

## Use Cases

Perfect for:
- **Competitive Programming** - Test solutions safely
- **Code Testing** - Run untrusted code
- **Education** - Learn about sandboxing
- **Development** - Test in isolated environments

## Contributing

Contributions welcome! Feel free to:
- Report issues
- Submit pull requests
- Suggest improvements
- Share your use cases

## Credits

- **NsJail** by Google - https://github.com/google/nsjail
- This guide and helper scripts are independent work

## License

This guide and helper scripts are released under MIT License.

NsJail itself is licensed under Apache License 2.0 by Google.

## Support

For issues with:
- **This guide/scripts**: Open an issue in this repository
- **NsJail itself**: See the [official NsJail repository](https://github.com/google/nsjail)

---

**Note**: This is a guide repository, not a fork of NsJail. You need to install NsJail separately (see Prerequisites).

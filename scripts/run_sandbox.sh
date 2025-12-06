#!/bin/bash
# Run a compiled C++ program in NsJail sandbox

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find nsjail binary (system-wide or in PATH)
if command -v nsjail &> /dev/null; then
    NSJAIL_BIN="nsjail"
else
    echo "Error: nsjail is not installed"
    echo ""
    echo "Please install nsjail first:"
    echo ""
    echo "Option 1: Build from source"
    echo "  sudo apt-get install -y autoconf bison flex gcc g++ git \\"
    echo "    libprotobuf-dev libnl-route-3-dev libtool make pkg-config protobuf-compiler"
    echo "  git clone https://github.com/google/nsjail.git"
    echo "  cd nsjail && make"
    echo "  sudo cp nsjail /usr/local/bin/"
    echo ""
    echo "Option 2: Use Docker"
    echo "  docker pull ghcr.io/google/nsjail"
    echo ""
    echo "See README.md for more details."
    exit 1
fi

# Default configuration
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/config/simple-sandbox.cfg"
PROGRAM="${PROJECT_ROOT}/test_program"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -p|--program)
            PROGRAM="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -c, --config FILE    Use specific config file (default: simple-sandbox.cfg)"
            echo "  -p, --program FILE   Program to run (default: test_program)"
            echo "  -h, --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Run test_program with default config"
            echo "  $0 -c sandbox.cfg                     # Use custom config"
            echo "  $0 -p ./my_program                    # Run different program"
            echo "  $0 -c sandbox.cfg -p ./my_program     # Custom config and program"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Verify files exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$PROGRAM" ]; then
    echo "Error: Program not found: $PROGRAM"
    exit 1
fi

if [ ! -x "$PROGRAM" ]; then
    echo "Error: Program is not executable: $PROGRAM"
    echo "Try: chmod +x $PROGRAM"
    exit 1
fi

# Convert to absolute path if relative
if [[ ! "$PROGRAM" = /* ]]; then
    PROGRAM="$(cd "$(dirname "$PROGRAM")" && pwd)/$(basename "$PROGRAM")"
fi

echo "========================================="
echo "Running program in NsJail sandbox"
echo "========================================="
echo "Config:  $CONFIG_FILE"
echo "Program: $PROGRAM"
echo "========================================="
echo ""

# Run the program in nsjail
$NSJAIL_BIN --config "$CONFIG_FILE" -- "$PROGRAM"

EXIT_CODE=$?
echo ""
echo "========================================="
echo "Sandbox execution completed"
echo "Exit code: $EXIT_CODE"
echo "========================================="

exit $EXIT_CODE

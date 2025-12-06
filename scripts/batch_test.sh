#!/bin/bash
# Batch test runner for NsJail sandbox
# Useful for running multiple test cases in competitive programming

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <program> <test_dir>"
    echo ""
    echo "Runs a program against all test cases in a directory"
    echo ""
    echo "Arguments:"
    echo "  program     Path to the compiled program to test"
    echo "  test_dir    Directory containing test input files"
    echo ""
    echo "Expected directory structure:"
    echo "  test_dir/"
    echo "    ├── test1.in"
    echo "    ├── test1.out  (optional - for validation)"
    echo "    ├── test2.in"
    echo "    ├── test2.out"
    echo "    └── ..."
    echo ""
    echo "Example:"
    echo "  $0 ./solution ./tests"
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

PROGRAM="$1"
TEST_DIR="$2"

# Verify program exists
if [ ! -f "$PROGRAM" ]; then
    echo -e "${RED}Error: Program not found: $PROGRAM${NC}"
    exit 1
fi

if [ ! -x "$PROGRAM" ]; then
    echo -e "${RED}Error: Program is not executable: $PROGRAM${NC}"
    exit 1
fi

# Verify test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo -e "${RED}Error: Test directory not found: $TEST_DIR${NC}"
    exit 1
fi

# Find all .in files
INPUT_FILES=$(find "$TEST_DIR" -name "*.in" | sort)

if [ -z "$INPUT_FILES" ]; then
    echo -e "${YELLOW}Warning: No .in files found in $TEST_DIR${NC}"
    exit 1
fi

# Count tests
TOTAL_TESTS=$(echo "$INPUT_FILES" | wc -l)
PASSED=0
FAILED=0
ERROR=0

echo "========================================"
echo "Running $TOTAL_TESTS test cases"
echo "Program: $PROGRAM"
echo "Test directory: $TEST_DIR"
echo "========================================"
echo ""

for input_file in $INPUT_FILES; do
    # Get test name
    test_name=$(basename "$input_file" .in)
    output_file="${input_file%.in}.out"
    
    echo -n "Test $test_name: "
    
    # Run in sandbox with timeout
    if output=$("${SCRIPT_DIR}/run_sandbox.sh" -p "$PROGRAM" < "$input_file" 2>&1); then
        # Check if expected output exists
        if [ -f "$output_file" ]; then
            # Extract only the program output (skip nsjail logs)
            actual_output=$(echo "$output" | sed -n '/Executing/,/exited with status/{ /Executing/d; /exited with status/d; p; }')
            expected_output=$(cat "$output_file")
            
            if [ "$actual_output" = "$expected_output" ]; then
                echo -e "${GREEN}PASSED${NC}"
                ((PASSED++))
            else
                echo -e "${RED}FAILED${NC} (output mismatch)"
                echo "  Expected:"
                echo "$expected_output" | sed 's/^/    /'
                echo "  Got:"
                echo "$actual_output" | sed 's/^/    /'
                ((FAILED++))
            fi
        else
            echo -e "${GREEN}RUN OK${NC} (no expected output to compare)"
            ((PASSED++))
        fi
    else
        echo -e "${RED}ERROR${NC} (runtime error or timeout)"
        ((ERROR++))
    fi
done

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed, $ERROR errors (out of $TOTAL_TESTS)"
echo "========================================"

# Exit with error if any test failed
if [ $FAILED -gt 0 ] || [ $ERROR -gt 0 ]; then
    exit 1
fi

exit 0

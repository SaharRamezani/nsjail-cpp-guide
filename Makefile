# Makefile for NsJail sandbox testing

CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra
TARGET = test_program
SOURCE = examples/test_program.cpp
EXAMPLE_TARGET = example_algo
EXAMPLE_SOURCE = examples/example_algo.cpp
FAILING_TARGET = failing_test
FAILING_SOURCE = examples/failing_test.cpp

.PHONY: all clean run run-simple run-advanced test examples

all: $(TARGET)

examples: $(TARGET) $(EXAMPLE_TARGET) $(FAILING_TARGET)

$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)

$(EXAMPLE_TARGET): $(EXAMPLE_SOURCE)
	$(CXX) $(CXXFLAGS) -o $(EXAMPLE_TARGET) $(EXAMPLE_SOURCE)

$(FAILING_TARGET): $(FAILING_SOURCE)
	$(CXX) $(CXXFLAGS) -o $(FAILING_TARGET) $(FAILING_SOURCE)

clean:
	rm -f $(TARGET) $(EXAMPLE_TARGET) $(FAILING_TARGET)

run: $(TARGET)
	./scripts/run_sandbox.sh

run-simple: $(TARGET)
	./scripts/run_sandbox.sh -c config/simple-sandbox.cfg

run-advanced: $(TARGET)
	./scripts/run_sandbox.sh -c config/sandbox.cfg

# Direct nsjail execution (requires nsjail in PATH)
test: $(TARGET)
	nsjail -Mo --chroot / --user 99999 --group 99999 \
		--time_limit 10 --rlimit_as 256 --rlimit_cpu 5 \
		-- ./$(TARGET)

help:
	@echo "Available targets:"
	@echo "  make          - Compile the test program"
	@echo "  make examples - Compile all example programs"
	@echo "  make clean    - Remove compiled binaries"
	@echo "  make run      - Run with default config (config/simple-sandbox.cfg)"
	@echo "  make run-simple   - Run with simple config"
	@echo "  make run-advanced - Run with advanced config"
	@echo "  make test     - Run with direct nsjail command"
	@echo "  make help     - Show this help message"

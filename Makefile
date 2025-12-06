# Makefile for NsJail sandbox testing

CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra
TARGET = test_program
SOURCE = test_program.cpp

.PHONY: all clean run run-simple run-advanced test

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./run_sandbox.sh

run-simple: $(TARGET)
	./run_sandbox.sh -c simple-sandbox.cfg

run-advanced: $(TARGET)
	./run_sandbox.sh -c sandbox.cfg

# Direct nsjail execution (requires nsjail in PATH)
test: $(TARGET)
	nsjail -Mo --chroot / --user 99999 --group 99999 \
		--time_limit 10 --rlimit_as 256 --rlimit_cpu 5 \
		-- ./$(TARGET)

help:
	@echo "Available targets:"
	@echo "  make          - Compile the test program"
	@echo "  make clean    - Remove compiled binary"
	@echo "  make run      - Run with default config (simple-sandbox.cfg)"
	@echo "  make run-simple   - Run with simple config"
	@echo "  make run-advanced - Run with advanced config"
	@echo "  make test     - Run with direct nsjail command"
	@echo "  make help     - Show this help message"

# Quick Start Guide - NsJail Sandbox

## What You Have

Your NsJail sandbox environment is ready to use! Here's what's been set up:

### Files Created
- ✅ `test_program.cpp` - Sample C++ program
- ✅ `test_program` - Compiled binary (executable)
- ✅ `simple-sandbox.cfg` - Basic isolation config
- ✅ `sandbox.cfg` - Advanced isolation config
- ✅ `run_sandbox.sh` - Convenient wrapper script
- ✅ `Makefile` - Build automation
- ✅ `README.md` - Full documentation

### NsJail Location
- Binary: `/home/sahar/Desktop/CP/NsJail/nsjail/nsjail`
- The script automatically finds this local binary

## Quick Commands

### Run Your Program in Sandbox
```bash
./run_sandbox.sh
```

### Compile and Run
```bash
make && make run
```

### Test Different Configs
```bash
./run_sandbox.sh -c simple-sandbox.cfg    # Basic isolation
./run_sandbox.sh -c sandbox.cfg           # Advanced isolation
```

### Run Your Own C++ Program
```bash
# 1. Compile your program
g++ -o my_program my_program.cpp -std=c++11

# 2. Run it in sandbox
./run_sandbox.sh -p ./my_program
```

## What the Sandbox Does

When you run `./run_sandbox.sh`, your program runs with:

### Isolation Features
- **Separate PID namespace** - Process sees itself as PID 1
- **Separate network namespace** - Isolated from host network
- **Separate user namespace** - Runs as UID 99999 (not root)
- **Read-only filesystem** - Can't modify system files
- **Writable /tmp** - Temporary storage available
- **No access to host processes** - Can't see or interact with them

### Resource Limits
- **Memory**: 256 MB
- **CPU time**: 5 seconds
- **Wall time**: 10 seconds
- **Max open files**: 32

### What It Can't Do
- ❌ Access your home directory (unless you mount it)
- ❌ Access network (isolated namespace)
- ❌ Modify system files (read-only root)
- ❌ See other processes on your system
- ❌ Use more than allocated resources

## Example: Running Untrusted Code

```bash
# Create a potentially dangerous program
cat > dangerous.cpp << 'EOF'
#include <iostream>
#include <fstream>

int main() {
    // This won't work - filesystem is read-only!
    std::ofstream file("/etc/bad_file");
    if (file.is_open()) {
        file << "Trying to write...";
        std::cout << "SUCCESS (shouldn't happen)" << std::endl;
    } else {
        std::cout << "BLOCKED: Cannot write to /etc" << std::endl;
    }
    return 0;
}
EOF

# Compile and run safely
g++ -o dangerous dangerous.cpp
./run_sandbox.sh -p ./dangerous
```

## Direct NsJail Commands

If you prefer using nsjail directly:

```bash
# Basic usage
./nsjail/nsjail -Mo --chroot / --user 99999 --group 99999 -- ./test_program

# With resource limits
./nsjail/nsjail -Mo \
    --chroot / \
    --user 99999 --group 99999 \
    --time_limit 10 \
    --rlimit_as 256 \
    --rlimit_cpu 5 \
    -- ./test_program

# Interactive shell in sandbox
./nsjail/nsjail -Mo --chroot / --user 99999 --group 99999 -- /bin/bash
```

## Common Scenarios

### 1. Test a Competitive Programming Solution
```bash
# Your CP solution
g++ -o solution solution.cpp -O2
./run_sandbox.sh -p ./solution < input.txt
```

### 2. Run Multiple Test Cases
```bash
for i in {1..5}; do
    echo "Test case $i:"
    ./run_sandbox.sh -p ./solution < test$i.txt
done
```

### 3. Check Resource Usage
The sandbox will automatically kill programs that:
- Run too long (> 10 seconds)
- Use too much memory (> 256 MB)
- Use too much CPU (> 5 seconds)

### 4. Mount Additional Directories
Edit `simple-sandbox.cfg` and add:
```
mount {
  src: "/home/sahar/data"
  dst: "/data"
  is_bind: true
  rw: false
}
```

## Troubleshooting

### "Cannot execute binary file"
Make sure the file is executable:
```bash
chmod +x ./test_program
```

### "nsjail: command not found"
The script should find the local nsjail binary. If not:
```bash
export PATH=$PATH:/home/sahar/Desktop/CP/NsJail/nsjail
```

### "Operation not permitted"
Some systems restrict user namespaces. Check:
```bash
sysctl kernel.unprivileged_userns_clone
# Should output: kernel.unprivileged_userns_clone = 1
```

If it's 0, enable it:
```bash
sudo sysctl -w kernel.unprivileged_userns_clone=1
```

## Next Steps

1. **Try the test program**: `./run_sandbox.sh`
2. **Create your own program**: Write, compile, and test
3. **Customize configs**: Edit `.cfg` files for your needs
4. **Read full docs**: Check `README.md` for advanced features

## Safety Note

While NsJail provides strong isolation, it's not perfect:
- Use for development and testing
- For production, consider additional security layers
- Always review untrusted code before running
- Keep your system and nsjail updated

## Learn More

- Configuration files: `simple-sandbox.cfg` and `sandbox.cfg`
- Full documentation: `README.md`
- NsJail source: `./nsjail/` directory
- Example configs: `./nsjail/configs/`

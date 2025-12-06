# 🚀 Quick Start

```bash
# Run the test program
./run_sandbox.sh

# Or use make
make run
```

# 🎯 Next Steps

## 1. Run Your Own Programs

```bash
# Create your program
cat > myprogram.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello from my sandboxed program!" << std::endl;
    return 0;
}
EOF

# Compile
g++ -o myprogram myprogram.cpp -std=c++11

# Run in sandbox
./run_sandbox.sh -p ./myprogram
```

## 2. Try Different Configurations

```bash
# Basic isolation (default)
./run_sandbox.sh -p ./myprogram

# Advanced isolation with more restrictions
./run_sandbox.sh -c sandbox.cfg -p ./myprogram
```

## 3. Test Resource Limits

The sandbox automatically enforces:
- **Memory limit**: 256 MB
- **CPU time limit**: 5 seconds
- **Wall time limit**: 10 seconds

Try this:
```cpp
#include <iostream>
#include <vector>

int main() {
    // This will hit memory limit
    std::vector<int> huge(100000000);  // ~400MB
    return 0;
}
```

## 4. Test Filesystem Isolation

```cpp
#include <fstream>
#include <iostream>

int main() {
    // This will fail - filesystem is read-only!
    std::ofstream file("/etc/test");
    if (!file.is_open()) {
        std::cout << "Success! Protected from writing to /etc" << std::endl;
    }
    return 0;
}
```

# 💡 Pro Tips

## Use Make for Quick Workflow
```bash
make          # Compile test_program
make run      # Compile and run in sandbox
make clean    # Remove binaries
make help     # See all options
```

## Direct NsJail Usage
```bash
# If you prefer direct control
./nsjail/nsjail -Mo --chroot / --user 99999 --group 99999 -- ./test_program
```

## Interactive Shell in Sandbox
```bash
./nsjail/nsjail -Mo --chroot / --user 99999 --group 99999 -- /bin/bash
```

## Run Multiple Test Cases
```bash
for i in {1..5}; do
    echo "=== Test $i ==="
    ./run_sandbox.sh -p ./solution < test$i.txt
done
```

# 🔒 Security Features Active

Your sandbox provides:

- ✅ **Process isolation** - Can't see host processes
- ✅ **Network isolation** - No network access
- ✅ **User namespace** - Runs as non-privileged user (99999)
- ✅ **Filesystem protection** - Read-only root, writable /tmp only
- ✅ **Resource limits** - CPU, memory, and time constraints
- ✅ **Mount namespace** - Separate filesystem view

# 📖 Documentation

- **Quick Start**: Read `QUICKSTART.md` for common scenarios
- **Full Docs**: Check `README.md` for advanced features
- **Config Files**: See `*.cfg` files for configuration examples
- **NsJail Docs**: Original documentation in `nsjail/` directory

# 🐛 Troubleshooting

## If Something Doesn't Work

1. **Check executable permissions**:
   ```bash
   chmod +x ./test_program ./run_sandbox.sh
   ```

2. **Verify NsJail binary**:
   ```bash
   ./nsjail/nsjail --help
   ```

3. **Check user namespaces** (if you get permission errors):
   ```bash
   sysctl kernel.unprivileged_userns_clone
   # Should be 1
   ```

4. **Use verbose mode** for debugging:
   ```bash
   ./nsjail/nsjail -v --config simple-sandbox.cfg -- ./test_program
   ```

# 🎓 Learning Resources

## Understanding What's Happening

When you run `./run_sandbox.sh`:

1. Script finds the NsJail binary
2. Loads configuration (resource limits, namespaces, mounts)
3. Creates isolated namespaces (PID, network, user, mount)
4. Maps your UID to 99999 inside sandbox
5. Mounts read-only root filesystem
6. Creates writable /tmp
7. Executes your program in this isolated environment
8. Enforces resource limits
9. Reports exit code and cleanup

## Key Concepts

- **Namespaces**: Linux kernel feature for isolation
- **cgroups**: Resource limiting
- **chroot**: Filesystem isolation
- **seccomp**: System call filtering (optional)
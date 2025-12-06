# Advanced NsJail Configuration Guide

This document provides detailed information about advanced NsJail configurations, security features, and advanced usage patterns.

## Table of Contents

- [Understanding NsJail](#understanding-nsjail)
- [Configuration Files Explained](#configuration-files-explained)
- [Advanced Configurations](#advanced-configurations)
- [Resource Limits](#resource-limits)
- [Filesystem Configuration](#filesystem-configuration)
- [Security Hardening](#security-hardening)
- [Troubleshooting](#troubleshooting)
- [Performance Tuning](#performance-tuning)

## Understanding NsJail

### What is NsJail?

NsJail is a process isolation tool that uses Linux namespaces, resource limits, and seccomp-bpf syscall filters to create a secure sandbox environment. It's designed to run untrusted code safely.

### Key Components

1. **Namespaces**: Provide isolation for different system resources
   - **PID namespace**: Process sees itself as PID 1
   - **Network namespace**: Isolated network stack
   - **Mount namespace**: Separate filesystem view
   - **User namespace**: UID/GID remapping
   - **IPC namespace**: Isolated inter-process communication
   - **UTS namespace**: Separate hostname

2. **cgroups**: Resource limiting and accounting
   - CPU time limits
   - Memory limits
   - Process limits

3. **Seccomp-BPF**: System call filtering (optional)
   - Restrict which syscalls can be made
   - Add extra security layer

## Configuration Files Explained

### simple-sandbox.cfg

Basic configuration suitable for most use cases:

```protobuf
name: "simple-cpp-sandbox"
description: "Basic isolation for C++ programs"

mode: ONCE
hostname: "sandbox"
cwd: "/"

time_limit: 10        # 10 seconds wall time
rlimit_as: 256        # 256 MB memory
rlimit_cpu: 5         # 5 seconds CPU time
rlimit_nofile: 32     # Max 32 open files

mount {
  src: "/"
  dst: "/"
  is_bind: true
  rw: false           # Read-only root
}

mount {
  dst: "/tmp"
  fstype: "tmpfs"
  rw: true            # Writable /tmp
  options: "size=16777216"  # 16MB
}

mount {
  src: "/proc"
  dst: "/proc"
  fstype: "proc"
}
```

### sandbox.cfg

Advanced configuration with stricter limits:

```protobuf
name: "advanced-cpp-sandbox"
description: "Stricter isolation with additional protections"

mode: ONCE
hostname: "isolated"
cwd: "/"

time_limit: 5         # Shorter time limit
rlimit_as: 128        # Less memory
rlimit_cpu: 3
rlimit_nofile: 16
rlimit_nproc: 1       # Only 1 process allowed

# Additional limits
rlimit_fsize: 1       # Max 1MB file writes

mount {
  src: "/"
  dst: "/"
  is_bind: true
  rw: false
  noexec: false
  nodev: true
  nosuid: true
}

mount {
  dst: "/tmp"
  fstype: "tmpfs"
  rw: true
  options: "size=8388608"  # 8MB
  noexec: false
  nodev: true
  nosuid: true
}

mount {
  src: "/proc"
  dst: "/proc"
  fstype: "proc"
}

# Enable seccomp
seccomp_policy_file: "/path/to/seccomp.policy"
```

## Advanced Configurations

### Mounting Additional Directories

To give your program access to specific directories:

```protobuf
# Mount input data (read-only)
mount {
  src: "/home/user/data"
  dst: "/data"
  is_bind: true
  rw: false
}

# Mount output directory (read-write)
mount {
  src: "/home/user/output"
  dst: "/output"
  is_bind: true
  rw: true
}
```

### Environment Variables

Set environment variables for sandboxed programs:

```protobuf
envar: "PATH=/usr/bin:/bin"
envar: "HOME=/tmp"
envar: "LANG=en_US.UTF-8"
```

### Working Directory

Set where the program starts:

```protobuf
cwd: "/workspace"

# Mount the workspace
mount {
  src: "/home/user/project"
  dst: "/workspace"
  is_bind: true
  rw: true
}
```

### User and Group Mapping

Control UID/GID mapping:

```protobuf
# Map current user to non-privileged user inside
uidmap {
  inside_id: "1000"
  outside_id: "1000"
  count: 1
}

gidmap {
  inside_id: "1000"
  outside_id: "1000"
  count: 1
}
```

## Resource Limits

### Memory Limits

```protobuf
# Virtual memory limit (in MB)
rlimit_as: 256

# You can also use rlimit_as_type
rlimit_as_type: SOFT  # or HARD
```

### CPU Limits

```protobuf
# CPU time in seconds
rlimit_cpu: 5

# Wall clock time (real time)
time_limit: 10
```

### File Limits

```protobuf
# Maximum open files
rlimit_nofile: 32

# Maximum file size (in MB)
rlimit_fsize: 10

# Maximum core dump size
rlimit_core: 0  # Disable core dumps
```

### Process Limits

```protobuf
# Maximum number of processes
rlimit_nproc: 1

# Stack size limit (in MB)
rlimit_stack: 8
```

## Filesystem Configuration

### Read-Only Root with Exceptions

```protobuf
# Root is read-only
mount {
  src: "/"
  dst: "/"
  is_bind: true
  rw: false
}

# But /tmp is writable
mount {
  dst: "/tmp"
  fstype: "tmpfs"
  rw: true
}

# And a specific work directory
mount {
  src: "/home/user/workspace"
  dst: "/work"
  is_bind: true
  rw: true
}
```

### Limiting Temporary Storage

```protobuf
mount {
  dst: "/tmp"
  fstype: "tmpfs"
  rw: true
  options: "size=16777216"  # 16MB limit
}
```

### Blocking Device Access

```protobuf
mount {
  src: "/"
  dst: "/"
  is_bind: true
  rw: false
  nodev: true   # No device files
  nosuid: true  # No setuid binaries
}
```

## Security Hardening

### Disable Network Access

Network is disabled by default with the `-N` flag or in config:

```protobuf
clone_newnet: true
```

### Disable New Privileges

```protobuf
no_new_privs: true
```

### Seccomp Filtering

Create a seccomp policy file to restrict system calls:

```
# seccomp.policy
POLICY example {
  KILL {
    ptrace,
    process_vm_readv,
    process_vm_writev
  }
  ALLOW {
    read,
    write,
    open,
    close,
    exit,
    exit_group
  }
}
```

Then enable in config:

```protobuf
seccomp_policy_file: "seccomp.policy"
```

### Personality Flags

Disable certain kernel features:

```protobuf
persona_addr_compat_layout: false
persona_mmap_page_zero: false
persona_read_implies_exec: false
persona_addr_limit_3gb: false
persona_addr_no_randomize: false
```

## Troubleshooting

### Permission Denied Errors

**Problem**: Program can't access files

**Solutions**:
1. Check mount configurations
2. Verify file permissions before sandboxing
3. Check UID/GID mappings
4. Mount the directory with proper permissions

```bash
# Check what mounts are active
./nsjail/nsjail -v -Mo --config simple-sandbox.cfg -- /bin/ls -la /
```

### Out of Memory Errors

**Problem**: Program killed for using too much memory

**Solutions**:
1. Increase `rlimit_as` limit
2. Optimize your program
3. Check for memory leaks

```protobuf
# Increase to 512 MB
rlimit_as: 512
```

### Time Limit Exceeded

**Problem**: Program doesn't finish in time

**Solutions**:
1. Increase `time_limit`
2. Optimize algorithm
3. Check for infinite loops

```protobuf
# Increase to 30 seconds
time_limit: 30
```

### Cannot Execute Binary

**Problem**: Binary runs outside sandbox but not inside

**Solutions**:
1. Check executable is not in noexec mount
2. Verify binary has execute permissions
3. Check binary dependencies

```bash
# Check dependencies
ldd ./your_program

# Ensure libraries are accessible in sandbox
```

### Namespace Errors

**Problem**: "Operation not permitted" when creating namespaces

**Solutions**:
1. Check kernel support:
```bash
sysctl kernel.unprivileged_userns_clone
```

2. Enable if needed:
```bash
sudo sysctl -w kernel.unprivileged_userns_clone=1
```

3. Run with appropriate privileges or use sudo

## Performance Tuning

### Minimize Overhead

1. **Use simpler configs** when possible
2. **Avoid unnecessary mounts**
3. **Disable unused namespaces** if not needed
4. **Use ONCE mode** instead of daemon mode

### Batch Processing

For multiple test cases:

```bash
# Pre-compile outside sandbox
g++ -O2 -o solution solution.cpp

# Run multiple times
for test in tests/*.txt; do
    ./run_sandbox.sh -p ./solution < "$test"
done
```

### Caching

NsJail doesn't cache filesystem state, so:
- Pre-compile binaries outside sandbox
- Use static linking when possible
- Minimize library dependencies

### Optimal Limits

Balance security and performance:

```protobuf
# For competitive programming
time_limit: 10      # Usually 2-10 seconds per problem
rlimit_as: 256      # 256MB typically enough
rlimit_cpu: 5       # Slightly less than wall time

# For general testing
time_limit: 30
rlimit_as: 512
rlimit_cpu: 15
```

## Command Line Options

### Common Flags

```bash
# Mode flags
-Mo, --mode ONCE          # Run once and exit (most common)
-Ml, --mode LISTEN        # Listen mode (daemon)
-Mr, --mode RERUN         # Rerun on exit

# Namespace flags
-n, --disable_clone_newnet    # Disable network isolation
-u, --disable_clone_newuser   # Disable user namespace
-p, --disable_clone_newpid    # Disable PID isolation

# Resource limits
-t, --time_limit SEC      # Wall time limit
--rlimit_as MB            # Virtual memory limit
--rlimit_cpu SEC          # CPU time limit
--rlimit_nofile NUM       # Open files limit

# User/Group
-U, --user UID            # Run as UID
-G, --group GID           # Run as GID

# Filesystem
-R, --chroot DIR          # Change root directory
--cwd DIR                 # Working directory

# Configuration
--config FILE             # Load config from file

# Debugging
-v, --verbose             # Verbose output
--log LOG_FILE            # Log to file
```

### Example Commands

```bash
# Minimal sandbox
./nsjail/nsjail -Mo --chroot / -- ./program

# With resource limits
./nsjail/nsjail -Mo --chroot / \
    --time_limit 10 \
    --rlimit_as 256 \
    --rlimit_cpu 5 \
    -- ./program

# With custom user
./nsjail/nsjail -Mo --chroot / \
    --user 99999 --group 99999 \
    -- ./program

# With config file
./nsjail/nsjail --config sandbox.cfg -- ./program

# Verbose mode for debugging
./nsjail/nsjail -v --config sandbox.cfg -- ./program
```

## Best Practices

### For Competitive Programming

1. **Use moderate limits**:
   - Time: 5-10 seconds
   - Memory: 256-512 MB
   - CPU: Half of wall time

2. **Allow /tmp access** for temporary files

3. **Mount test case directory** read-only

4. **Pre-compile** solutions outside sandbox

### For Security Testing

1. **Use strict limits**:
   - Time: 5 seconds
   - Memory: 128 MB
   - Single process only

2. **Enable seccomp** filtering

3. **Mount minimal filesystems**

4. **Use read-only root**

5. **Disable network** completely

### For Development

1. **More relaxed limits** for debugging

2. **Mount source directories** read-write

3. **Keep verbose logging** enabled

4. **Allow multiple processes** if needed

## Additional Resources

- [NsJail Official Repository](https://github.com/google/nsjail)
- [Linux Namespaces Documentation](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [cgroups Documentation](https://www.kernel.org/doc/Documentation/cgroup-v1/cgroups.txt)
- [Seccomp Documentation](https://www.kernel.org/doc/Documentation/prctl/seccomp_filter.txt)

## Examples Repository

See the `examples/` directory for:
- Sample programs demonstrating different features
- Configuration file templates
- Test cases and batch testing scripts

---

For basic usage, see [QUICKSTART.md](QUICKSTART.md).
For setup instructions, see [SETUP_COMPLETE.md](SETUP_COMPLETE.md).

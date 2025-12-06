# Publishing Your NsJail Guide to GitHub

## Step-by-Step Instructions

### Option 1: New Repository (Recommended)

This creates a clean repository with just your guide and scripts, without the full NsJail source code.

#### Step 1: Prepare Your Files

Create a new directory with only your files:

```bash
# Create new directory
mkdir ~/nsjail-cpp-guide
cd ~/nsjail-cpp-guide

# Copy your files (NOT the nsjail subdirectory)
cp ~/Desktop/CP/NsJail/run_sandbox.sh .
cp ~/Desktop/CP/NsJail/batch_test.sh .
cp ~/Desktop/CP/NsJail/simple-sandbox.cfg .
cp ~/Desktop/CP/NsJail/sandbox.cfg .
cp ~/Desktop/CP/NsJail/Makefile .
cp ~/Desktop/CP/NsJail/test_program.cpp .
cp ~/Desktop/CP/NsJail/example_algo.cpp .
cp ~/Desktop/CP/NsJail/QUICKSTART.md .
cp ~/Desktop/CP/NsJail/SETUP_COMPLETE.md .
cp ~/Desktop/CP/NsJail/README_FOR_GITHUB.md README.md
cp ~/Desktop/CP/NsJail/LICENSE .
```

#### Step 2: Update Scripts

Edit `run_sandbox.sh` to remove the hardcoded nsjail path:

```bash
# Change this section:
if [ -f "${SCRIPT_DIR}/nsjail/nsjail" ]; then
    NSJAIL_BIN="${SCRIPT_DIR}/nsjail/nsjail"
elif command -v nsjail &> /dev/null; then
    NSJAIL_BIN="nsjail"

# To this:
if command -v nsjail &> /dev/null; then
    NSJAIL_BIN="nsjail"
```

#### Step 3: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `nsjail-cpp-guide` (or your preferred name)
3. Description: "Complete guide for using NsJail to sandbox C++ programs"
4. Make it Public
5. **Don't** initialize with README (you already have one)
6. Click "Create repository"

#### Step 4: Push Your Code

```bash
cd ~/nsjail-cpp-guide

# Initialize git
git init

# Add files
git add .

# Commit
git commit -m "Initial commit: NsJail C++ sandbox guide"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/nsjail-cpp-guide.git

# Push
git branch -M main
git push -u origin main
```

### Option 2: Document in Existing Directory

If you want to keep the nsjail source but publish as documentation:

#### Add .gitignore

```bash
cd ~/Desktop/CP/NsJail
cat > .gitignore << 'EOF'
# Exclude NsJail source (cloned from Google)
nsjail/

# Compiled binaries
test_program
example_algo
*.o
*.out
*.exe

# Temporary files
*.tmp
.DS_Store
EOF
```

#### Create New Repo

```bash
# Initialize git (this will be YOUR repo, not Google's)
git init

# Add your files
git add .

# Commit
git commit -m "Add NsJail setup guide and helper scripts"

# Create new repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/nsjail-setup-guide.git
git branch -M main
git push -u origin main
```

## What to Include in Your Repository

### ✅ Include These (Your Work)
- `run_sandbox.sh` - Your wrapper script
- `batch_test.sh` - Your testing utility
- `*.cfg` files - Your configurations
- `test_program.cpp` - Your example
- `example_algo.cpp` - Your example
- `Makefile` - Your build file
- All `.md` documentation files
- `LICENSE` - MIT license for your work

### ❌ Don't Include These (Google's Code)
- `nsjail/` directory - This is Google's repository
- Built NsJail binary - Users should build their own

## Add a Note to README

Make it clear that:
1. This is a **guide**, not a fork of NsJail
2. Users need to install NsJail separately
3. Credit Google for NsJail itself

## Recommended Repository Structure

```
nsjail-cpp-guide/
├── README.md              # Main readme (use README_FOR_GITHUB.md)
├── LICENSE                # MIT license for your scripts
├── QUICKSTART.md          # Quick start guide
├── SETUP_COMPLETE.md      # Detailed guide
├── run_sandbox.sh         # Your wrapper script
├── batch_test.sh          # Your testing script
├── simple-sandbox.cfg     # Basic config
├── sandbox.cfg            # Advanced config
├── Makefile               # Build automation
├── examples/
│   ├── test_program.cpp   # Example 1
│   └── example_algo.cpp   # Example 2
└── .gitignore             # Exclude binaries
```

## Additional Recommendations

### 1. Add Topics to Your GitHub Repo
- nsjail
- sandbox
- security
- cpp
- competitive-programming
- containers
- linux

### 2. Create a Good README.md
- I've created `README_FOR_GITHUB.md` - rename it to `README.md`
- Clear instructions for installing NsJail
- Credit Google's NsJail project
- Show examples

### 3. Add GitHub Actions (Optional)
Test that your scripts work:

```yaml
# .github/workflows/test.yml
name: Test Scripts
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install NsJail
        run: |
          sudo apt-get update
          sudo apt-get install -y autoconf bison flex gcc g++ git \
            libprotobuf-dev libnl-route-3-dev libtool make pkg-config protobuf-compiler
          git clone https://github.com/google/nsjail.git
          cd nsjail && make
          sudo cp nsjail /usr/local/bin/
      - name: Test setup
        run: |
          make
          ./run_sandbox.sh
```

## Summary Commands

Here's the complete process:

```bash
# 1. Create clean directory
mkdir ~/nsjail-cpp-guide
cd ~/nsjail-cpp-guide

# 2. Copy your files
cp ~/Desktop/CP/NsJail/{run_sandbox.sh,batch_test.sh,*.cfg,*.cpp,Makefile,*.md,LICENSE} .
mv README_FOR_GITHUB.md README.md

# 3. Update run_sandbox.sh to use system nsjail
# (Edit manually to remove hardcoded path)

# 4. Initialize git
git init
git add .
git commit -m "Initial commit: NsJail C++ sandbox guide"

# 5. Create repo on GitHub, then push
git remote add origin https://github.com/YOUR_USERNAME/nsjail-cpp-guide.git
git branch -M main
git push -u origin main
```

## Legal Notes

- Your scripts and documentation: **Your copyright** (MIT License)
- NsJail itself: **Google's copyright** (Apache 2.0)
- Make this distinction clear in your README
- Give proper credit to Google's NsJail project

You're creating a **guide/tutorial repository**, not forking NsJail!

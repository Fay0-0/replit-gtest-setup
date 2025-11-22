#!/bin/bash

echo "🔧 Starting FULL GoogleTest Setup for Replit (Auto-Healing Mode)…"

#########################################
# 1. Ensure required directories exist
#########################################

mkdir -p src
mkdir -p tests

#########################################
# 2. Create sample test.cpp ALWAYS
#########################################

echo "📝 Writing tests/test.cpp"
cat > tests/test.cpp << 'EOF'
#include <gtest/gtest.h>

int add(int a, int b);

TEST(AdditionTest, Basic) {
    EXPECT_EQ(add(2, 3), 5);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
EOF

#########################################
# 3. Create main.cpp ONLY if missing
#########################################

if [ ! -f src/main.cpp ]; then
echo "📝 Creating src/main.cpp"

cat > src/main.cpp << 'EOF'
int add(int a, int b) {
    return a + b;
}

int main() {
    return 0;
}
EOF
else
  echo "✔ src/main.cpp exists — keeping it"
fi

#########################################
# 4. Auto-generate CMakeLists.txt ALWAYS
#########################################

echo "🛠 Writing CMakeLists.txt"

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(ReplitGTestProject)

set(CMAKE_CXX_STANDARD 17)

add_executable(test_runner
    src/main.cpp
    tests/test.cpp
)

find_package(GTest REQUIRED)
target_link_libraries(test_runner
    GTest::gtest
    GTest::gtest_main
    pthread
)
EOF

#########################################
# 5. Auto-generate replit.nix ALWAYS
#########################################

echo "🛠 Writing replit.nix"

cat > replit.nix << 'EOF'
{ pkgs }: {
  deps = [
    pkgs.gcc
    pkgs.cmake
    pkgs.gtest
    pkgs.pkg-config
  ];
}
EOF

#########################################
# 6. Auto-generate .clangd (IntelliSense fix)
#########################################

echo "🧠 Writing .clangd"

cat > .clangd << 'EOF'
CompileFlags:
  Add:
    - -I/usr/include
    - -I/nix/store
EOF

#########################################
# 7. Auto-generate .replit with self-healing RUN button
#########################################

echo "⚙ Writing .replit configuration"

cat > .replit << 'EOF'
run = """
# If build folder missing OR Makefile missing → recreate fully
if [ ! -f build/Makefile ]; then 
  rm -rf build
  mkdir -p build
  cd build
  cmake ..
else
  cd build
fi

make
./test_runner
"""

[commands]

run_tests = """
if [ ! -f build/Makefile ]; then 
  rm -rf build
  mkdir -p build
  cd build
  cmake ..
else
  cd build
fi

make
./test_runner
"""

run_main = "g++ src/main.cpp -o main && ./main"
EOF

#########################################
# 8. Perform FIRST CMake run automatically
#########################################

echo "🔨 Performing initial build setup…"

rm -rf build
mkdir build
cd build
cmake ..
make

echo "🎉 GoogleTest Installation Complete!"
echo "🔥 Run button is now fully configured"
echo "➡ Use run_main or run_tests fro


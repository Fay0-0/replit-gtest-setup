#!/bin/bash

echo "🔧 Starting FULL GoogleTest Setup for Replit (CMake Mode)…"

#########################################
# 1. Ensure folders
#########################################

mkdir -p src
mkdir -p tests

#########################################
# 2. Write tests/test.cpp
#########################################

echo "📝 Writing tests/test.cpp"

cat > tests/test.cpp << 'EOF'
#include <gtest/gtest.h>

int add(int a, int b); // from main_app

TEST(AdditionTest, Basic) {
    EXPECT_EQ(add(2, 3), 5);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
EOF

#########################################
# 3. Create src/main.cpp ONLY IF MISSING
#########################################

if [ ! -f src/main.cpp ]; then

echo "📝 Creating src/main.cpp"

cat > src/main.cpp << 'EOF'
int add(int a, int b) {
    return a + b;
}

#include <iostream>
int main() {
    std::cout << "main_app running! add(2,3)=" << add(2,3) << std::endl;
    return 0;
}
EOF

else
  echo "✔ src/main.cpp exists — keeping it"
fi

#########################################
# 4. Correct CMakeLists (2 separate executables)
#########################################

echo "🛠 Writing CMakeLists.txt"

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(ReplitGTestProject)

set(CMAKE_CXX_STANDARD 17)

# Main program
add_executable(main_app
    src/main.cpp
)

# GoogleTest runner
add_executable(test_runner
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
# 5. Write replit.nix
#########################################

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
# 6. Write .clangd
#########################################

cat > .clangd << 'EOF'
CompileFlags:
  Add:
    - -I/usr/include
    - -I/nix/store
EOF

#########################################
# 7. Write .replit (FULL FIXED)
#########################################

echo "⚙ Writing .replit"

cat > .replit << 'EOF'
run = """
# Auto-heal build
if [ ! -f build/Makefile ]; then
  rm -rf build
  mkdir build
  cd build
  cmake ..
else
  cd build
fi

make main_app
./main_app
"""

[commands]

run_main = """
if [ ! -f build/Makefile ]; then
  rm -rf build


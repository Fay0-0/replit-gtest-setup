#!/bin/bash

echo "🔧 Starting FULL GoogleTest Setup for Replit (CMake Mode)…"

#########################################
# 1. Ensure directories exist
#########################################

mkdir -p src
mkdir -p tests

#########################################
# 2. Create tests/test.cpp (ALWAYS)
#########################################

echo "📝 Writing tests/test.cpp"
cat > tests/test.cpp << 'EOF'
#include <gtest/gtest.h>

int add(int a, int b);  // from main_app

TEST(AdditionTest, Basic) {
    EXPECT_EQ(add(2, 3), 5);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
EOF

#########################################
# 3. Create src/main.cpp ONLY IF missing
#########################################

if [ ! -f src/main.cpp ]; then
echo "📝 Creating src/main.cpp"

cat > src/main.cpp << 'EOF'
int add(int a, int b) {
    return a + b;
}

#include <iostream>
int main() {
    std::cout << "Main app running! add(2,3)=" << add(2,3) << "\\n";
    return 0;
}
EOF
else
  echo "✔ src/main.cpp exists — keeping it"
fi

#########################################
# 4. Full CMakeLists.txt (Two Executables)
#########################################

echo "🛠 Writing CMakeLists.txt"

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(ReplitGTestProject)

set(CMAKE_CXX_STANDARD 17)

# Main application
add_executable(main_app
    src/main.cpp
)

# GoogleTest executable
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
# 6. IntelliSense Fix (.clangd)
#########################################

echo "🧠 Writing .clangd"

cat > .clangd << 'EOF'
CompileFlags:
  Add:
    - -I/usr/include
    - -I/nix/store
EOF

#########################################
# 7. .replit (Fully Working Run Buttons)
#########################################

echo "⚙ Writing .replit configuration"

cat > .replit << 'EOF'
run = """
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
  mkdir build
  cd build
  cmake ..
else
  cd build
fi
make main_app
./main_app
"""

run_tests = """
if [ ! -f build/Makefile ]; then
  rm -rf build
  mkdir build
  cd build
  cmake ..
else
  cd build
fi
make test_runner
./test_runner
"""
EOF

#########################################
# 8. Initial CMake run (Auto Build)
#########################################

echo "🔨 Performing initial build…"

rm -rf build
mkdir build
cd build
cmake ..
make

echo "🎉 GoogleTest Installation Complete!"
echo "➡ Run button executes MAIN APP"
echo "➡ 'run_tests' runs GoogleTests"
echo "➡ 'run_main' runs main_app manually"


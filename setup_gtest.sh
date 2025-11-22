#!/bin/bash

echo "🚀 Starting GoogleTest Setup (Optimized Clean Version)..."

#######################################
# 0. CLEAN ENVIRONMENT (ONLY NECESSARY)
#######################################

rm -rf build src tests CMakeFiles CMakeCache.txt cmake_install.cmake
rm -f main main_app test_runner libadd_lib.a
rm -f run_active.sh shell.nix repl-runner.sh replit.nix.backup
rm -f Makefile setup.sh

#######################################
# 1. CREATE PROJECT STRUCTURE
#######################################

mkdir -p src
mkdir -p tests

#######################################
# 2. src/add.h
#######################################

cat > src/add.h << 'EOF'
#pragma once
int add(int a, int b);
EOF

#######################################
# 3. src/add.cpp
#######################################

cat > src/add.cpp << 'EOF'
#include "add.h"
int add(int a, int b) { return a + b; }
EOF

#######################################
# 4. src/main.cpp
#######################################

cat > src/main.cpp << 'EOF'
#include "add.h"
#include <iostream>

int main() {
    std::cout << "main_app running! add(2,3) = " << add(2,3) << std::endl;
    return 0;
}
EOF

#######################################
# 5. tests/test.cpp
#######################################

cat > tests/test.cpp << 'EOF'
#include <gtest/gtest.h>
#include "add.h"

TEST(AdditionTest, Basic) {
    EXPECT_EQ(add(2,3), 5);
    EXPECT_EQ(add(-1,1), 0);
}
int main(int c, char** v) {
    testing::InitGoogleTest(&c, v);
    return RUN_ALL_TESTS();
}
EOF

#######################################
# 6. CMakeLists.txt
#######################################

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(ReplitGTestProject)

set(CMAKE_CXX_STANDARD 17)

add_library(add_lib src/add.cpp)

add_executable(main_app src/main.cpp)
target_link_libraries(main_app add_lib)

add_executable(test_runner tests/test.cpp)
target_include_directories(test_runner PRIVATE src)

find_package(GTest REQUIRED)

target_link_libraries(test_runner
    add_lib
    GTest::gtest
    GTest::gtest_main
    pthread
)
EOF

#######################################
# 7. replit.nix
#######################################

cat > replit.nix << 'EOF'
{ pkgs }: {
  deps = [
    pkgs.gcc
    pkgs.cmake
    pkgs.gtest
  ];
}
EOF

#######################################
# 8. run_main.sh
#######################################

cat > run_main.sh << 'EOF'
#!/bin/bash
echo "▶ Running main_app..."
if [ ! -f build/Makefile ]; then
  rm -rf build && mkdir build && cd build && cmake ..
else
  cd build
fi
make main_app
./main_app
EOF
chmod +x run_main.sh

#######################################
# 9. run_tests.sh
#######################################

cat > run_tests.sh << 'EOF'
#!/bin/bash
echo "🧪 Running GoogleTests..."
if [ ! -f build/Makefile ]; then
  rm -rf build && mkdir build && cd build && cmake ..
else
  cd build
fi
make test_runner
./test_runner
EOF
chmod +x run_tests.sh

#######################################
# 10. run_select.sh (FANCY MENU)
#######################################

cat > run_select.sh << 'EOF'
#!/bin/bash

while true; do
  echo "========================================="
  echo "🔥 Replit GTest Runner — Choose an action"
  echo "========================================="
  echo "1) ▶ Run main_app"
  echo "2) 🧪 Run GoogleTests"
  echo "3) ❌ Exit"
  echo "========================================="
  read -p "Enter choice (1/2/3): " c

  case "$c" in
    1) bash run_main.sh; break ;;
    2) bash run_tests.sh; break ;;
    3) echo '👋 Exiting runner.'; exit 0 ;;
    *) echo "⚠ Invalid choice. Try again." ;;
  esac
done
EOF
chmod +x run_select.sh

#######################################
# 11. CLEAN .replit (NO GARBAGE)
#######################################

cat > .replit << 'EOF'
run = "bash -ic './run_select.sh'"

[commands]
run_main = "bash -ic './run_main.sh'"
run_tests = "bash -ic './run_tests.sh'"

[packager]
ignoredFiles = ["run_active.sh"]
EOF

#######################################
# 12. INITIAL BUILD
#######################################

mkdir build && cd build && cmake .. && make

echo "🎉 Clean GoogleTest setup complete!"
echo "➡ Click RUN to use the menu"
echo "➡ run_main for main_app"
echo "➡ run_tests for GoogleTests"


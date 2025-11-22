#!/bin/bash

echo "🧹 Starting FULL cleanup — restoring original Replit C++ environment..."

##############################################################
# 1. REMOVE ALL DIRECTORIES CREATED BY SETUP
##############################################################

echo "🗑 Removing CMake and GoogleTest directories..."
rm -rf build
rm -rf src
rm -rf tests

##############################################################
# 2. REMOVE GENERATED FILES
##############################################################

echo "🗑 Removing generated files..."
rm -f CMakeLists.txt
rm -f .clangd
rm -f cmake_install.cmake
rm -f test_runner
rm -f main_app
rm -f main_app*
rm -f test_runner*
rm -f CMakeCache.txt
rm -f *.o

echo "🗑 Removing CMake internal build metadata..."
rm -rf CMakeFiles

##############################################################
# 3. RESTORE DEFAULT replit.nix
##############################################################

echo "🔄 Restoring default replit.nix..."
cat > replit.nix << 'EOF'
{ pkgs }: {
  deps = [
    pkgs.gcc
  ];
}
EOF

##############################################################
# 4. RESTORE DEFAULT .replit
##############################################################

echo "🔄 Restoring default .replit..."
cat > .replit << 'EOF'
run = "./main"
compile = "make"
EOF

##############################################################
# 5. RESTORE DEFAULT Makefile
##############################################################

echo "🛠 Restoring default Makefile..."
cat > Makefile << 'EOF'
CC = g++
CFLAGS = -std=c++17 -Wall
TARGET = main

all: $(TARGET)

$(TARGET): main.cpp
	$(CC) $(CFLAGS) main.cpp -o $(TARGET)

clean:
	rm -f $(TARGET)
EOF

##############################################################
# 6. RESTORE main.cpp IF MISSING
##############################################################

if [ ! -f main.cpp ]; then
  echo "📝 Restoring default main.cpp"
  cat > main.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello World!" << std::endl;
    return 0;
}
EOF
else
  echo "✔ Keeping existing main.cpp"
fi

##############################################################
# 7. REBUILD & RUN DEFAULT PROJECT
##############################################################

echo "🔨 Building default project using Makefile..."
make

echo "🏃 Running default program..."
./main

echo "🎉 Cleanup complete!"
echo "🧼 Replit C++ environment fully restored!"


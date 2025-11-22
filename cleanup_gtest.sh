#!/bin/bash

echo "🧹 Starting cleanup — restoring original Replit C++ environment..."

rm -rf build src tests
rm -f CMakeLists.txt .clangd test_runner main_app main main-debug replit.nix

#########################################
# Restore default replit.nix
#########################################

cat > replit.nix << 'EOF'
{ pkgs }: {
  deps = [
    pkgs.gcc
  ];
}
EOF

#########################################
# Restore default .replit
#########################################

cat > .replit << 'EOF'
run = "./main"
compile = "make"
EOF

#########################################
# Restore default Makefile
#########################################

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

#########################################
# Restore main.cpp if missing
#########################################

if [ ! -f main.cpp ]; then
cat > main.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello from restored Replit C++ environment!" << std::endl;
    return 0;
}
EOF
fi

#########################################
# Auto-build and run
#########################################

make
./main

echo "🎉 Cleanup complete and running!"


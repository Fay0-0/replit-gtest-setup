#!/bin/bash

echo "🧹 Starting cleanup — restoring original Replit C++ environment..."

#########################################
# 1. Remove GTest folders and files
#########################################

echo "🗑 Removing build/, tests/, and src/ folders..."
rm -rf build
rm -rf tests
rm -rf src

echo "🗑 Removing generated files..."
rm -f CMakeLists.txt
rm -f .clangd
rm -f test_runner
rm -f main_app
rm -f main
rm -f main-debug

#########################################
# 2. Restore default replit.nix
#########################################

echo "🔄 Restoring default replit.nix..."

cat > replit.nix << 'EOF'
{ pkgs }: {
  deps = [
    pkgs.gcc
  ];
}
EOF

#########################################
# 3. Restore default Makefile
#########################################

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

#########################################
# 4. Restore default .replit
#########################################

echo "🔄 Restoring default .replit..."

cat > .replit << 'EOF'
run = "./main"
compile = "make"
EOF

#########################################
# 5. Restore main.cpp if missing
#########################################

if [ ! -f "main.cpp" ]; then
  echo "📝 main.cpp missing — restoring default main.cpp"
  cat > main.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello from restored Replit C++ environment!" << std::endl;
    return 0;
}
EOF
else
  echo "✔ Keeping your existing main.cpp"
fi

#########################################
# 6. Auto-compile + auto-run (NO USER ACTION NEEDED)
#########################################

echo "🔨 Compiling using restored Makefile..."
make

echo "🏃 Running the restored default program..."
./main

#########################################
# 7. Done!
#########################################

echo "🎉 Cleanup complete!"
echo "🧼 Replit C++ environment restored and program executed successfully."


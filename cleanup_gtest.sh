#!/bin/bash

echo "🧹 Starting cleanup — restoring original Replit C++ environment..."

#########################################
# 1. Remove auto-generated dirs
#########################################

echo "🗑 Removing build/, tests/, and src/ folders..."
rm -rf build
rm -rf tests
rm -rf src

#########################################
# 2. Remove auto-generated files
#########################################

echo "🗑 Removing generated config files..."
rm -f CMakeLists.txt
rm -f .clangd
rm -f test_runner
rm -f main
rm -f main-debug

#########################################
# 3. Restore original replit.nix (C++)
#########################################

echo "🔄 Restoring default Replit C++ replit.nix..."

cat > replit.nix << 'EOF'
{ pkgs }: {
  deps = [
    pkgs.gcc
  ];
}
EOF

#########################################
# 4. Restore default .replit
#########################################

echo "🔄 Restoring default .replit configuration..."

cat > .replit << 'EOF'
compile = "make -s"
run = "./main"
entrypoint = "main.cpp"
hidden = ["main", "**/*.o", "**/*.d", ".ccls-cache", "Makefile"]

[nix]
channel = "stable-24_05"

[gitHubImport]
requiredFiles = [".replit", "replit.nix", ".ccls-cache"]

[debugger]
support = true

[debugger.compile]
command = ["make", "main-debug"]
noFileArgs = true

[debugger.interactive]
transport = "stdio"
startCommand = ["dap-cpp"]

[debugger.interactive.initializeMessage]
command = "initialize"
type = "request"

[debugger.interactive.initializeMessage.arguments]
adapterID = "cppdbg"
clientID = "replit"
clientName = "replit.com"
columnsStartAt1 = true
linesStartAt1 = true
locale = "en-us"
pathFormat = "path"
supportsInvalidatedEvent = true
supportsProgressReporting = true
supportsRunInTerminalRequest = true
supportsVariablePaging = true
supportsVariableType = true

[debugger.interactive.launchMessage]
command = "launch"
type = "request"

[debugger.interactive.launchMessage.arguments]
MIMode = "gdb"
arg = []
cwd = "."
environment = []
externalConsole = false
logging = {}
miDebuggerPath = "gdb"
name = "g++ - Build and debug active file"
request = "launch"
setupCommands = [
    { description = "Enable pretty-printing for gdb", ignoreFailures = true, text = "-enable-pretty-printing" }
]
stopAtEntry = false
type = "cppdbg"

[languages]

[languages.cpp]
pattern = "**/*.{cpp,h}"

[languages.cpp.languageServer]
start = "ccls"

[agent]
expertMode = true
EOF

#########################################
# 5. Finished!
#########################################

echo "🎉 Cleanup complete!"
echo "🧼 Your Replit project is now fully restored to default C++ environment."


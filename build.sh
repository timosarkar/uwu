#!/bin/bash

set -e  # Exit on any error

echo "Building Tengu SimpleGo to C99 transpiler..."

# Check if ANTLR4 jar exists
if [ ! -f "antlr-4.13.1-complete.jar" ]; then
    echo "Downloading ANTLR4..."
    curl -O https://www.antlr.org/download/antlr-4.13.1-complete.jar
fi

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "Error: Java is required but not installed."
    echo "Please install Java (OpenJDK or Oracle JDK) and try again."
    exit 1
fi

# Generate Go parser files from grammar
java -Xmx500M -cp "antlr-4.13.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool -Dlanguage=Go Tengu.g4


# Fix package declarations in generated files
echo "Fixing package declarations..."
sed -i '' 's/package parser/package main/g' tengu_*.go

# Build the Go project
echo "Building Go project..."
go mod tidy
go build -o tengu .

echo "Build completed successfully!"
echo "Executable: ./tengu"
echo ""
echo "Usage:"
echo "  ./tengu                    # Run the transpiler"
echo "  ./tengu > output.c         # Generate C code to file"
echo "  go run .                   # Run directly without building"

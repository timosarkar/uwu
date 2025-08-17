package main

import (
	"flag"
	"fmt"
	"github.com/antlr4-go/antlr/v4"
	"os"
	"os/exec"
)

func main() {
	filename := flag.String("file", "", "filename")
	flag.Parse()

	if *filename == "" {
		fmt.Println("Please provide an input file with -file")
		return
	}

	input, err := os.ReadFile(*filename)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return
	}

	is := antlr.NewInputStream(string(input))
	lexer := NewTenguLexer(is)
	stream := antlr.NewCommonTokenStream(lexer, 0)
	parser := NewTenguParser(stream)
	tree := parser.Prog()

	generator := &CGenerator{}
	cCode := generator.VisitProg(tree).(string)

	fmt.Println("#include <stdio.h>")

	// output C code to a temporary file
	tmpfile, err := os.CreateTemp("", "temp-*.c")
	if err != nil {
		panic(err)
	}
	defer tmpfile.Close()

	if _, err := tmpfile.Write([]byte(cCode)); err != nil {
		panic(err)
	}

	// compile using cc
	outputBinary := "a.out"
	cmd := exec.Command("cc", tmpfile.Name(), "-o", outputBinary)
	if out, err := cmd.CombinedOutput(); err != nil {
		fmt.Printf("Error compiling to native binary: %v\n", err)
		fmt.Println(string(out))
		return
	}

	fmt.Println("Compilation successful, binary:", outputBinary)
}
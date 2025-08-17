package main

import (
    "fmt"
    "github.com/antlr4-go/antlr/v4"
    "os"
)

func main() {
    input, err := os.ReadFile("test.sg")
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
    fmt.Println(cCode)
}

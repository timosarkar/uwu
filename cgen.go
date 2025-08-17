package main

import (
    "fmt"
    "strings"
)

// Visitor that generates C99 code
type CGenerator struct {
    output strings.Builder
}

// Visit the whole program
func (c *CGenerator) VisitProg(ctx IProgContext) interface{} {
    for _, stmt := range ctx.AllStatement() {
        c.VisitStatement(stmt)
    }
    return c.output.String()
}

// Visit import statements
func (c *CGenerator) VisitImportStmt(ctx IImportStmtContext) interface{} {
    filename := ctx.STRING().GetText()
    c.output.WriteString(fmt.Sprintf("#include %s\n", filename))
    return nil
}

// Visit function declarations
func (c *CGenerator) VisitFuncDecl(ctx IFuncDeclContext) interface{} {
    name := ctx.IDENT().GetText()
    ret := "int" // simple mapping; you can enhance later
    params := ""
    if ctx.ParamList() != nil {
        for _, p := range ctx.ParamList().AllParam() {
            pname := p.IDENT(0).GetText()
            ptype := mapType(p.IDENT(1).GetText())
            params += fmt.Sprintf("%s %s, ", ptype, pname)
        }
        params = strings.TrimSuffix(params, ", ")
    }
    c.output.WriteString(fmt.Sprintf("%s %s(%s) {\n", ret, name, params))
    for _, stmt := range ctx.Block().AllStmt() {
        c.VisitStmt(stmt)
    }
    c.output.WriteString("}\n\n")
    return nil
}

// Visit statements (function calls)
func (c *CGenerator) VisitStmt(ctx IStmtContext) interface{} {
    // Function call: IDENT '(' IDENT ')'
    funcName := ctx.IDENT(0).GetText()
    argName := ctx.IDENT(1).GetText()
    c.output.WriteString(fmt.Sprintf("    %s(%s);\n", funcName, argName))
    return nil
}

// Visit struct declarations
func (c *CGenerator) VisitStructDecl(ctx IStructDeclContext) interface{} {
    name := ctx.IDENT().GetText()
    c.output.WriteString(fmt.Sprintf("typedef struct {\n"))
    for _, f := range ctx.StructFields().AllStructField() {
        fname := f.IDENT(0).GetText()
        ftype := mapType(f.IDENT(1).GetText())
        c.output.WriteString(fmt.Sprintf("    %s %s;\n", ftype, fname))
    }
    c.output.WriteString(fmt.Sprintf("} %s;\n\n", name))
    return nil
}

// Visit statement - dispatch to appropriate visitor method
func (c *CGenerator) VisitStatement(ctx IStatementContext) interface{} {
    if ctx.ImportStmt() != nil {
        return c.VisitImportStmt(ctx.ImportStmt())
    } else if ctx.FuncDecl() != nil {
        return c.VisitFuncDecl(ctx.FuncDecl())
    } else if ctx.StructDecl() != nil {
        return c.VisitStructDecl(ctx.StructDecl())
    }
    return nil
}

func mapType(t string) string {
    switch t {
    case "type": return "int"
    case "returntype": return "int"
    default: return t
    }
}

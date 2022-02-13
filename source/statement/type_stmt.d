module statement.type_stmt;

import std.array;

import pegged.grammar;

import compiler.compiler, compiler.type, compiler.variable, compiler.type;
import language.statement;

/** Compiles a TYPE statement */
class Type_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        if(compiler.inTypeDef) {
            compiler.displayError("Type definition already started");
        }

        string typeName = join(this.node.children[0].children[0].matches);
        if(compiler.getTypes().defined(typeName)) {
            compiler.displayError("Type " ~ typeName ~ " already exists");
        }

        Type t = new Type(typeName);
        t.isPrimitive = false;
        compiler.getTypes().add(t);
        compiler.currentTypeDef = t;
        compiler.inTypeDef = true;
    }
}

/** Compiles a field definition statement */
class Field_def : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    private Variable variable;
    
    void process()
    {
        if(!compiler.inTypeDef) {
            compiler.displayError("Syntax error");
        }

        ParseTree var = this.node.children[0].children[0];
        VariableReader reader = new VariableReader(var, compiler);
        this.variable = reader.read();

        if(compiler.currentTypeDef.hasField(variable.name)) {
            compiler.displayError("Field " ~ variable.name ~ " is already defined in this Type");
        }
        if(variable.isArray()) {
            compiler.displayError("Fields cannot be arrays");
        }
        
        try {
            compiler.currentTypeDef.addField(variable);
        }
        catch(Exception e) {
            compiler.displayError(e.msg);
        }
    }
}

/** Compiles an END TYPE statement */
class Endtype_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        if(!compiler.inTypeDef) {
            compiler.displayError("Not in Type definition");
        }

        compiler.currentTypeDef = null;
        compiler.inTypeDef = false;
    }
}
module compiler.labelcollection;

import std.algorithm.searching, std.string;
import compiler.compiler;

/**
 * Holds a collection of labels and performs validation, adding
 * or finding individual labels
 */
class LabelCollection
{
    private Compiler compiler;
    private string[] labels;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
    }

    /** Returns true if the label exists in the current scope */
    public bool exists(string label, bool localOnly = true)
    {
        bool canFindLocal = canFind(this.labels, this.getLocalName(label));
        bool canFindGlobal = canFind(this.labels, this.getGlobalName(label));
        if(localOnly) {
            return canFindLocal;
        } else {
            return canFindLocal || canFindGlobal;
        }
    }

    /** Checks if label already exists, adds if not */
    public void add(string label)
    {
        label = toLower(label);
        string localLabel = this.getLocalName(label);
        if(this.exists(label)) {
            this.compiler.displayError("Label '" ~ label ~ "' already exists in this scope");
        }
        this.labels ~= localLabel;
    }

    /** Translates label to its counterpart in the assembly source */
    public string getReferenceToLabel(string label)
    {
        if(canFind(this.labels, this.getLocalName(label))) {
            return "L_" ~ this.getLocalName(label);
        }
        if(canFind(this.labels, this.getGlobalName(label))) {
            return "L_" ~ this.getGlobalName(label);
        }

        assert(0);
    }

    /** TODO! This should be private! Translates label to its counterpart in the assembly source */
    public string toAsmLabel(string label)
    {
        return "L_" ~ this.getLocalName(label);
    }

    /** Getter method for labels */
    public string[] getLabels()
    {
        return this.labels;
    }

    /** Translates label to global, ie. src1.label */
    private string getGlobalName(string label)
    {
        label = toLower(label);
        return this.compiler.currentFileId ~ "." ~  label;
    }

    /** Translates label to local, ie. src1.proc_name.label */
    private string getLocalName(string label)
    {
        label = toLower(label);
        return this.compiler.currentFileId ~ "."
                ~ (this.compiler.inProcedure ? (this.compiler.currentProcName ~ "." ~ label) : label);
    }
}
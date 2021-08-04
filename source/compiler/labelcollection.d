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
    public bool exists(string label)
    {
        return canFind(this.labels, this.getLocalName(label));
    }

    /** Checks if label already exists, adds if not */
    public void add(string label)
    {
        label = toLower(label);
        string localLabel = this.getLocalName(label);
        if(this.exists(label)) {
            this.compiler.displayError("Label '" ~ localLabel ~ "' already exists");
        }
        this.labels ~= localLabel;
    }

    /** Translates label to its counterpart in the assembly source */
    public string toAsmLabel(string label)
    {
        return "L_" ~ this.getLocalName(label);
    }

    /** Getter method for labels */
    public string[] getLabels()
    {
        return this.labels;
    }

    /** Translates label to local, ie. src1.proc_name.label */
    private string getLocalName(string label)
    {
        label = toLower(label);
        return this.compiler.currentFileId ~ "."
                ~ (this.compiler.inProcedure ? (this.compiler.currentProcName ~ "." ~ label) : label);
    }
}
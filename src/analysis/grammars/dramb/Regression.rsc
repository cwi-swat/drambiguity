@synopsis{Utility to run stored tests against a new grammar and report new issues}
module analysis::grammars::dramb::Regression

import Exception;
import IO;
import List;
import ParseTree;
import ValueIO;
import analysis::grammars::dramb::Model;
import analysis::grammars::dramb::Util;
import util::Maybe;
import util::Monitor;

@synopsis{Models the bad things that can happen when we parse old strings with a new grammar}
data ParsingRegression
    = error(str sentence, Symbol nonTerminal, loc src)
    | ambiguity(str sentence, Symbol nonTerminal, Tree cluster)
    | crash(str sentence, Symbol nonTerminal, value exception)
    | ok(str sentence, Symbol nonTerminal)
    ;

@synopsis{Run the stored regression test sentences against a new grammar}
@description{
This function runs the stashed sentences in the model against a new version of the grammar.
It returns `true` if no new errors are detected, and `false` if there are.

If this function returns `false` then it's time to run ((drAmbiguity)) interactively to:
* either fix the examples to reflect to the new grammar (for example  the syntax has changed)
* or fix the grammar to make sure no new ambiguities or errors are introduced anymore.
}
@benefits{
* Use this as a `test` function in your own syntax project, and run it during continuous integration testing. 

:::info
It's best to use IO::findResources to locate the textual value file that stores your drAmbiguity model.
:::
}
@pitfalls{
* This function does not provide the diagnostics features of ((drAmbiguity)). It's better to use the interactive tool for that.
}
bool testForParsingRegressions(type[&T <: Tree] newGrammar, loc oldModelLocation) {
    messages = runRegressionTests(newGrammar, oldModelLocation);

    if (messages == []) {
        return true;
    }
    parseErrors = [m | m <- messages, m is error];
    ambiguities = [m | m <- messages, m is ambiguity];
    crashes = [m | m <- messages, m is crash];
    
    println(
        "The regression test failed with <if (parseErrors != []) {>
        '   - <size(parseErrors)> new parse errors<}><if (ambiguities != []) {>
        '   - <size(ambiguities)> new ambiguous sentences<}><if (crashes != []) {>
        '   - <size(crashes)> new unexpected crashes<}>
        '"
    );
    
    return false;
}

@synopsis{Reads the old model from a textual value file and then continues to run the regression tests.}
@description{
Models are stored as textual values, because the save and load dialogs of salix-core, which ((drAmbiguity)) uses, read and write that format.
}
list[ParsingRegression] runRegressionTests(type[&T <: Tree] newGrammar, loc oldModelLocation)
    = runRegressionTests(newGrammar, readTextValueFile(#Model, oldModelLocation));

@synopsis{This is the workhorse that runs the regression tests; it simulates exactly what the interactive tool also does when a grammar is updated.}
@description{
By reparsing all the examples in the stored model we find out if there are new parse errors, new ambiguities, or new crashes.
We collect the errors and return them as a list for later inspection. However, it is recommended to use the interactive
((drAmbiguity)) tool for diagnostics rather than studying this list.
}
list[ParsingRegression] runRegressionTests(type[&T <: Tree] newGrammar, Model m, str label="Regression tests") {
    results = loopJob(m.examples, ParsingRegression (<str ex, Symbol s, Maybe[Tree] _t, str _st>) {
        try {
            tt = reparse(newGrammar, s, ex);
            
            if (/a: amb(_) := tt) {
                println("[ERROR] ambiguous <type(s, ())>: \n\t`<ex>`");
                return ambiguity("<a>", symbol(a), a);
            }
        }
        catch ParseError(l): {
            println("[ERROR] parse error for <type(s,())> at <l>:\n\t`<ex>`");
            return error(ex, s, l);
        }
        catch value v: {
            println("[ERROR] unexpected crash for <type(s,())> in:\n\t`<ex>`");
            return crash(ex, s, v);
        }

        return ok(ex, s);
    }, label=label);

    // only the regressions are reported
    return [r | r <- results, !(r is ok)];
}
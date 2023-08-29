---
title: Treatment
---

Once the ((Diagnostics)) stage has provided an idea for treating the ambiguity, we can apply this treatment (or another) to the current grammar.
1. The `Grammar` tab allows you to change the grammar at will, 
2. Then we tag the new version with a descriptive name (enter the text and move the focus out of the input box)
3. Then we `Commit` a new version, which becomes the new grammar. And a new parser is generated for every relevant non-terminal.
4. The `Sentence` view will be automatically updated:
   * the *current* sentence is re-parsed, and re-diagnosed with the new parser
   * all the *stashed* sentences are re-parsed and generally diagnosed (ok, error, ambiguity)
5. We may inspect the status of the current sentence, _and_ the damage done to all the stashed sentences. See also ((Prevention)).

It is not unheard of that a treatment has an unexpected side-effect in the stashed examples, or even on the current example.
This is why we manage the versions of the grammars meticulously. If you regret the latest fix, move back to the `Grammar` tab
and revert to any previous version. The reversion will have the same effect as committing a new grammar. 

![grammar tab]((grammar-editor.png))
---
title: Ambiguity
---

So what is ambiguity? Where does it come from?

Ambiguity happens when there are more than a single parse tree, produced by a (generated) parser, for a given input (sub)sentence.
Comparable to a parse error, ambiguity is reported _after_ parsing has completed. A typical
example:

```rascal-prepare
import ParseTree;
import vis::Text;
```

```rascal-shell,continue,error
syntax E = [a-z] | E "+" E;
parse(#E, "e+e+e");
```

The parser threw the `Ambiguity` exception, but we could let it build all the alternatives as well:
```rascal-shell,continue
t = parse(#E,"e+e+e", allowAmbiguity=true);
prettyTree(t)
```

This shows a pretty representation of the parse forest, where under the ❖ diamond we spot two
alternatives derivations. They correspond to these two interpretations:
* `(e+e)+e`
* `e+(e+e)`

We can also show the raw parse tree representation:
```rascal-shell,continue
Tree x = t;
```

The above diagnosis hints at a treatment, which when applied indeed solves the problem:
```rascal-shell,continue
syntax F = [a-z] | left F "+" F;
prettyTree(parse(#F, "e+e+e"));
```

The simple example aside, ambiguity of context-free grammars is not decidable in general. There do exist static analyses
that do a good approximation, but they are slow and take a lot of memory. Nevertheless for human beings predicting it is also hard, because an
ambiguity emerges from the accidental combination of many production rules in the grammar _and_
their accidental application for an example input. It can be a bit hard, and a lot boring, if you don't use the right tools.

The goal of "disambiguation" is to change a Rascal grammar such that one of the trees in this forest
goes away, and the other remains. Preferably this choice is implemented via a declarative mechnism
in Rascal syntax definitions. It is also possible to program a tree filter in Rascal "manually".


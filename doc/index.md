---
title: Why Dr Ambiguity
---

Dr Ambiguity is an experimental, yet comprehensive (interactive) toolkit for the
* ((Detection))
* ((Diagnostics)), 
* ((Treatment)), and
* ((Prevention))
of ambiguous parse forests as produced by parsers generated from context-free grammars in Rascal.

While engineering grammars in Rascal, **ambiguity** is a continuous and complex challenge. The hope is that using
Dr Ambiguity, newbees will get the hang of it sooner, and experts will sooner be done. Both
groups are expected to make fewer errors while using Dr Ambiguity as opposed to manual grammar engineering.

:::warning
Dr Ambiguity is still experimenal academic software and may sometimes be slow or buggy. However,
we expect using Dr Ambiguity will still beat staring at grammars and parse forests by a long shot :-)
:::

## What is ambiguity?

Ambiguity happens when there are more than a single parse tree for a given input (sub)sentence.
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
t = parse(#F, "e+e+e");
prettyTree(t)
```

The simple example aside, ambiguity of context-free grammars is not decidable in general. There do exist static analyses
that do a good approximation, but they are slow and take a lot of memory. Nevertheless for human beings predicting it is also hard, because an
ambiguity emerges from the accidental combination of many production rules in the grammar _and_
their accidental application for an example input. It can be a bit hard, and a lot boring, if you don't use the right tools.

The goal of "disambiguation" is to change a Rascal grammar such that one of the trees in this forest
goes away, and the other remains. Preferably this choice is implemented via a declarative mechnism
in Rascal syntax definitions. It is also possible to program a tree filter in Rascal "manually".


## Well `^!#!^#@`, why do I have to disambiguate my Rascal grammars?

Ambiguity never arises as a problem for parser generators that generate **deterministic** parsers.
Rascal generates a fast **non-deterministic parser** from your grammar, and this is why ambiguity can happen.
The question is now what do you get back anyway for this price you are paying? And next, how can
Dr Ambiguity help you lower the price?

Non-deterministic parsing technology, like the Earley, GLR, SGLR, GLL and SGLL algorithms, all
branch out parallel parse stacks when faces with a so-called parsing "conflict". And with that parsing conflicts
are a thing of the past. A conflict happens
when a deterministic parser can not decide based on the next input token and the current state of the
parser what should be done next. Should it predict another rule, and which one, or accept a piece of the input (shift)?
To avoid conflicts, you have to write "factor" your grammar in a certain style (LL or LR style), which leads to 
many additional non-terminals. It also shapes your grammar further away from the semantics of the language. 
Most importantly, avoiding conflicts manually in the grammar entails having to make a scanner and scan the input first. That way
an `i` on the input is already decided to be an identifier `ifNotOnly` or a keyword `if` using the scanners
heuristics of "reserve keywords" and "longest match". Scanners and their heuristics exist to make the parsers that come
after deterministics. However, many programming languages and DSLs do not fit the heuristics of scanners at all, 
and their grammars are non-deterministic in any style. Hence non-deterministic parsing helps avoid a lot
of manual grammar hacking. 

The benefits of non-deterministic parsing summarized:
* free shape of rules, any context-free grammar goes: means no more factoring, easy to extend with new rules, and "modular" grammars.
* no more LL/LR conflicts: no more hard to diagnose and even harder to remedie details of parsing algorithms which are different for every algorithm.
* no more scanner: more real languages covered, also helps with modular extensibility, and elegance, DRY principles
* near linear parsing efficiency for PL-like syntax; means low cost of the above

Non-deterministic parsing is called "generalizing parsing" or "context-free general parsing" in literature.
It is an interesting study subject, but it is **irrelevant** to the use of Dr Ambiguity. And that may be 
the best benefit of these algorithms:
* the semantics of the parser follows exactly, the semantics of the context-free grammar, nothing more and nothing less.

This latter property enables the existence of people who are experts in disambiguation, yet know nothing about
the innner workings of GLL and GLR, and also of the Dr Ambiguity tool which uses an interface to a generated 
parser but never looks into its inner workings.

## What is ambiguity engineering, and what features of Dr Ambiguity help with it?

These are the challenges that a grammar engineer faces with respect to ambiguity:
1. We want to ((Detection))[detect] more ambiguity, before our users do so accidentally. 
1. Once we have an example, we need to ((Diagnostics))[diagnose] the instance to figure out the **causes** of ambiguity.
1. The next step is ambiguity ((Treatment)) where we select an appropriate **disambiguation mechanism** to remove (at least one of) the earlier detected causes.
1. For the foreseeable future we want to ((Prevention))[prevent] our grammar from regressing to this specific ambiguity. We need to have some form of automated **regression testing**.
1. When all our ambiguities have been detected, diagnosed, treated and tested, we might seek a **proof of unambiguity**. 

Proof of unambiguity is not for Dr Ambiguity. There is a tool called "AmbiDexter" which you can try for that. Proving unambiguity is undecidable, has many parameters to tweak and its expensive in time and space. With Dr Ambiguity we strive for an interactive and usable experience, so we focus on the other challenes. All the other challenges
are addressed by Dr Ambiguity. You can read about how to use it, respectively, here:
* ((Detection))
* ((Diagnostics)), 
* ((Treatment))
* ((Prevention))

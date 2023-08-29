---
title: Non-determinism
---


> Why do I have to disambiguate my Rascal grammars? This seems like a problem solved in other parser generators...

Well, other parser generators have other problems. Rascal, like its predecessor SDF2, trades generality for
determinism because that brings certain advantages, explained here. It's a design trade-off and ambiguity is the price.

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
after deterministic. However, many programming languages and DSLs do not fit the heuristics of scanners at all, 
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

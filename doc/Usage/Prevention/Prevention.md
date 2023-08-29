---
title: Prevention
---

The stash of sentences on the `Sentences` tab is a valuable source of information, for when a grammar
must be fixed, extended or refactored for an outside reason. Next to this all changes to a  grammar
are causes of new trouble, which is why the `Grammar` tab offers to save important versions of the grammar 
over time.

* Save the stash using the `File` [menu]((Usage)), and to reload the stash with every new version of the grammar.
* Also save the versions of the grammar in the same go, to compare the semantics of the grammar with older version where necessary.

It is possible (and easy) to run the stashed sentences during continuous integration by calling Dr Ambiguity API functions
in a Rascal test function. This way you can use the list of stashed sentences as an important regression test,
when someone changes the source code of the underlying grammar.

Regression testing like this goes a long way in preventing ambiguity. The reason is that ambiguity
is often introduced into existing grammars by adding more features to a language. The more rules there are,
the more possible interactions, the more chance for ambiguity. An early-detection mechanism like the stashed
sentences is important.

When such a new ambiguity arises on existing sentences, the `Sentence` tab with its `Use` button for each
sentence makes it very easy to quickly assess the damage and think about mitigating solutions.
---
title: Using Dr Ambiguity
---

There are 4 main usage scenarios for Dr Ambiguity. They initially play out in this order, but there is no
restriction on any order of using these tools later.

* ((Detection))
* ((Diagnostics))
* ((Treatment))
* ((Prevention))

## Starting the tool

But first, we have to start Dr Ambiguity. This typically goes by the following steps:
1. Add a dependency to Dr Ambiguity to your pom.xml.
2. Get a grammar loaded into the terminal, say with start non-terminal `start[Program]`. You can type in a grammar or import a module with a grammar. Anything goes.
3. Start Dr Ambiguity by `drAmbiguity(#start[Program])`. Rascal will reify the grammar as a value, and pass it into the tool.

Then there exist different ways to save the state of a grammar analysis and continue later,
for example to test with a modified grammar if previous sentences are still unambiguous. 
See ((Prevention)) for more details on regression testing with Dr Ambiguity.
These other ways of booting up the tool are all explained in the API documentation.

You can also start Dr Ambiguity with an ambiguous tree example for immediate ((Diagnostics)), using `drAmbiguity(#start[Program], exampleForest)`.

## The four main views and the file menu

The file menu can be used to store and retrieve the full state of Dr Ambiguity. This includes all data
use like the grammar, the example sentences for regression testing, and the current input sentence.

![File Menu]((file-menu.png))

The grammar tab shows the current grammar _and_ the history of grammar versions.
On the top right you can tag the current grammar with a name and store it in the version history.
More information about this tab is explained in ((Treatment)) where we fix the ambiguities.

![Grammar editor and version history]((grammar-editor.png))

The sentence tab shows the sentence-under-study and a stash of sentences on the TODO list, or on the regression check list.
There is a general diagnostic view to the right, which displays the verdict for the current sentence. The buttons below
are explained in ((Detection)) and ((Diagnostics)), as they help searching for new ambiguities, and simplifying and explaining
ambiguity, on demand. The list of stashed sentences is important. Each record maintains the effect of the _current_ grammar
to parsing said sentence.

![Sentence editor and sentence stash]((sentence-editor.png))

The graphics tab repeats the general diagnosis for the _current_ example sentence for the _current_ grammar and 
shows a visual side-by-side view of two alternative parse trees.

![Graphical view of current ambiguous sentence]((graphics-view.png))

Finally, the [Diagnosis]((Diagnostics)) tab displays a readable report, which is preferably read from top to bottom,
analyzing the differences between each pair of alternative trees and proposing ((Treatment)) where possible. Typical
diagnostics may span several pages including side-by-side comparisons on a syntax rule level and on a token-by-token
level. Almost all analyses end with alternative proposals for resolving the ambiguity.

![Human readable diagnostics and treatment report]((diagnostics-report.png))


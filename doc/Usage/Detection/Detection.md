---
title: Ambiguity Detection
---

To detect new ambiguity in an existing grammar:
1. [Start Dr Ambiguity]((Usage))
2. Open the Sentence tab
3. Press the `Generate` button

If Dr Ambiguity finds new examples, they will stash all of them in the sentence stash below. Each of the examples will be diagnoses as `amb` and you can select one to work on by pressing
the `select` button. More on this in the ((Diagnostics)) part of these documentation pages.

![Sentence viewer]((sentence-editor.png))

If Dr Ambiguity can not find new examples, it will complain with an warning at the bottom of the screen. Such `no ambiguous sentences found` errors can accumulate. If you wish to clear the screen, please
use the `Clear` button to the right.

The sentence generation algorithm is inherently stochastic. It will generate many random sentences to parse, and
continue searching until the work is done. The amount of work that it will invest is select by the slide bar under the Generate button.

:::info
It does not hurt to press the `Generate` button a few times; which is often more useful than dragging the slider all the way to the right.
:::

Investing a lot of work could lead to many similar ambiguities which are all solved in the same way. It is better to 
waste time on each specific instance by searching for a few instances only.

After you have found a suitable amount of examples (say three), it is time to move on to the ((Diagnosis)) features of Dr Ambiguity.



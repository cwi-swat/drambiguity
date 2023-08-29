---
title: Diagnostics
---

We assume here that you have found an ambiguous sentence, either accidentally or using the `Generate` button explained on the ((Detection)) page.
Now we are still showing the `Sentences` tab.

Typically the following steps are taken:
1. We use the `Simplify` button a number of times to ask Dr Ambiguity to simplify the problem to the bare essence. Simpler sentences are stashed using the `Stash` button, and optionally the complex examples are removed from the stash using the `RM` button.
2. If there is `Nested Ambiguity` the `Sentences` diagnostics pain to the right reports this, and a `Focus` button allows us to focus on the deepest nested ambiguity. It is always better to diagnose and treat these first!
2. When we have focused and simplified enough, we go and see the `Graphic` tab to learn a bit about what we are looking at.
3. Then we quickly move to the `Diagnostics` page, because the graphic is usually just confusing.

The diagnostics page explains what the commonalities and differences are between each pair of alternatives in the top ambiguity cluster.
* if an ambiguity exists, it is a different tree for the same input, for the same non-terminal
* the differences between the tree are the **causes** of the ambiguity, because if they did not exist, the ambiguity would not exist
* so Dr Ambiguity meticulously explains detailed differences between each pair of trees. Each pair gets a new section header in the report.
* at the end of each section, Dr Ambiguity proposes one or more solutions for the ambiguity. Each solution removes the aforementioned causes. More on how to apply the proposed fixes in the ((Treatment)) part of these pages.

:::warning
Not every treatment is "syntax safe". This means that it can happen that removing the cause for one of the alternatives, *also removes the cause for the other alternative*!
This will then result in a parse error in the `Sentence` tab. More on this in the ((Treatment)) part of the documentation.
:::

:::info
Dr Ambiguity is not all knowing or complete in any sense. It can diagnose the reasons for typical ambiguous scannerless grammars in programming languages and domain specific languages. It 
does not, however, diagnose the causes of worst case ambiguous context-free grammars as found in literature. It is focused on real-world and realistic grammars. And, like a real GP, in particular it
can diagnose the kind of ambiguities that it has a treatment for.
:::
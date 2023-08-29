---
title: Documentation
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

If you have not heard of ((Ambiguity)) yet, then [here]((Ambiguity)) is a rapid introduction.

If you feel that you shouldn't have to learn about ((Ambiguity)) at all, then [here]((NonDeterminism)) is your excuse: ((NonDeterminism)). Ambiguity it is caused by the fact that Rascal features context-free general ([non-deterministic]((NonDeterminism))) parsing that has many beneficial properties, and one less beneficial one. Namely that is ambiguity.
Dr Ambiguity is an attempt at mitigating the effects of ambiguity on grammar and parser engineering with Rascal.

## What is ambiguity engineering, and what features of Dr Ambiguity help with it?

Ambiguity arises from the complex interactions between the many rules of a (non-deterministic) grammar.
Not all non-deterministic grammars have ambiguities, only some. When they do, there are certain sub-sentences.

These are the challenges that a grammar engineer faces with respect to ambiguity:
1. We want to [detect]((Detection)) more ambiguity, before our users do so accidentally. 
1. Once we have an example, we need to [diagnose]((Diagnostics)) the instance to figure out the **causes** of ambiguity.
1. The next step is ambiguity ((Treatment)) where we select an appropriate **disambiguation mechanism** to remove (at least one of) the earlier detected causes.
1. For the foreseeable future we want to [prevent]((Prevention)) our grammar from regressing to this specific ambiguity. We need to have some form of automated **regression testing**.
1. When all our ambiguities have been detected, diagnosed, treated and tested, we might seek a **proof of unambiguity**. 

Proof of unambiguity is not for Dr Ambiguity. There is a tool called "AmbiDexter" which you can try for that. Proving unambiguity is undecidable, has many parameters to tweak and its expensive in time and space. With Dr Ambiguity we strive for an interactive and usable experience, so we focus on the other challenges. All the other challenges
are addressed by Dr Ambiguity. You can read about how to use it, respectively, here:
* ((Detection))
* ((Diagnostics)), 
* ((Treatment))
* ((Prevention))

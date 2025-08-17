---
date: 2025-08-17 12:00
description: Notes from a session on coding workflows where the actual issue wasn’t “agents” or “gates” but trust. 
tags: AI, Zero-Trust, Engineering-Notes, LLM
---

# Gemini is a Pro and ChatGPT 5 Thinking is Thinking It’s Smart

To address the brittleness of monolithic code generation, a popular alternative is an iterative, multi-agent workflow. I took this design as a starting point for my evaluation: a system where a preparator gathers context, an architect creates a plan, a coder executes it, and a reviewer validates the output.

So, I decided to see how the top-tier AIs would evaluate the approach. I took the description to two models: Google's Gemini 2.5 Pro and OpenAI's ChatGPT 5 Thinking and asked to evaluate this workflow. What are the downsides? Does it make sense?

Predictably, both models did what LLMs do best: they started hallucinating praise. They immediately dived into detailing the approach, showering it with compliments on its "sophistication" and "robustness." ChatGPT even generated a 15-minute report. Both completely missed the forest for the trees. They saw a complex system and assumed it was a good one, failing to address the fundamental flaw in every single step.

The flaw is this: I have zero trust in the output of any LLM agent.

My experience with models from OpenAI, Google, Anthropic, and others has shown me they are, at their absolute best, talented juniors. They game specifications, writing trivial tests to "prove" their buggy code works. Their knowledge is built on a foundation of mediocre open-source code, so they happily reproduce common anti-patterns. An agentic system built with these models is just a house of cards—a sequence of untrustworthy actions producing an untrustworthy result.

This was the real issue I wanted to discuss. So I pushed back, explicitly introducing my "Zero Trust" framework to the conversation. I laid out my concerns about agents gaming specs and having flawed priors. This is where the paths diverged sharply.

ChatGPT 5 Thinking struggled. Even with the "Zero Trust" concept handed to it, its suggestions remained tactical and superficial: better prompting, more review steps, adding linters. I gave it near-direct pointers, trying to guide it toward a methodology that builds trust from the ground up. It never got there. It was stuck in a loop of suggesting more layers on top of a broken foundation.

Gemini's response was different. Once I framed the problem as one of Zero Trust, something clicked. It didn't just suggest adding another review layer. It went straight to the heart of professional software engineering and proposed the one thing that could serve as a non-negotiable contract with an untrustworthy agent: **Test-Driven Development (TDD).**

It understood that the only way to manage a "talented junior" is to remove ambiguity and the opportunity to cheat. You don't ask it to "write a feature and test it." You provide an executable specification—a suite of failing tests—and give it one, clear objective: make these tests pass.

This single interaction was incredibly telling. It wasn't about raw intelligence. It was about an understanding of professional discipline. When presented with a systemic trust issue, one model offered a whole warehouse of band-aids while the other reached for a scalpel from a surgeon's toolkit.

Ultimately, building a useful AI coding assistant isn't about creating the most complex, multi-agent Rube Goldberg machine. It's about designing a system of constraints and verifiable contracts that can channel the chaotic output of a junior-level intelligence into a trustworthy, professional result. The "Zero Trust" approach is, I believe, the only way forward. And the best tool for that job is the one that understands what it means to be a professional, not just the one that thinks it's smart.
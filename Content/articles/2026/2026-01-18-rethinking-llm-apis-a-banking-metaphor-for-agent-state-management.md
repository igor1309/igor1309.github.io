---
date: 2026-01-18 12:00
description: Coming from banking systems and iOS development, I found the distributed systems metaphor for LLM APIs limiting. Here's a different way to think about state that might help build better agent intuition.
tags: LLM, AI Agents, Architecture, State Management, APIs
---

# Rethinking LLM APIs: A Banking Metaphor for Agent State Management

I've been following the discussion around [Armin Ronacher's insightful post on LLM APIs as a synchronization problem](https://lucumr.pocoo.org/2025/11/22/llm-apis/) and [Mario Zechner's thoughtful response](https://mariozechner.at/posts/2025-11-22-armin-is-wrong/). Both make compelling points about the challenges of hidden state, provider opacity, and practical architecture.

Armin correctly identifies real pain: message-based APIs force quadratic costs and obscure internal KV caches and reasoning traces. Mario offers pragmatic wisdom: treat providers as black boxes and manage what you control client-side. Both perspectives feel right, yet the distributed systems/CRDT framing left me searching for a better mental model.

Having spent years working with banking systems before focusing on iOS development, a different analogy clicked for me: **bank accounts**.

## The Bank Account Model

Your bank account *balance* is state. You can query it, deposit, withdraw, transfer. But the bank's internal systems—risk models, liquidity pools, fraud detection, collateral management—are completely proprietary and hidden. That's not a bug; it's the design.

Inter-bank transfers work fine via standardized protocols (SWIFT, ACH) because everyone agrees on the *observable state*: sender account, amount, recipient account, timestamp. No one demands insight into the sending bank's VaR calculations or receiving bank's reserve ratios. If there's inconsistency, you reconcile via statements—client-side.

This maps cleanly to LLM APIs:

```
Bank Account          →   LLM Conversation
├── Balance (query)     →   Get current message history
├── Deposit/Withdraw   →   Append message, get completion  
├── Transaction ID     →   Provider session/cache token
└── Statement          →   Local checkpoint/persistence
```

Providers like OpenAI or Anthropic are the banks. Their "balance" is your conversation state. Their hidden internals (reasoning traces, attention patterns) are like stress tests—no one outside gets to see them, nor should they expect to.

## Why This Metaphor Helps Agentic Intuition

1. **Accept Opacity as Feature**: Banks hide internals for good reasons (IP, stability, competition). Same for LLM providers—reasoning traces contain proprietary signals. Demanding exposure is like asking JPMorgan to share their derivatives book.

2. **Focus on Observable Contracts**: Build agents around reliable interfaces (messages as transactions). Frameworks like LangGraph's checkpoints become your "monthly statements"—reconciliation points for debugging and resumption.

3. **Client-Side Reconciliation**: When state diverges (hallucinations, tool failures), replay from checkpoints like matching bank statements. Durable execution (Temporal, Inngest) handles the orchestration.

4. **Multi-Provider Portability**: Switch from OpenAI to Claude like transferring between banks. Lose some efficiency (no shared cache), but core state (messages) migrates cleanly.

## Practical Implications for Agent Building

```
Task → Agent → LLM Call → Tool Results → Checkpoint
                    ↑
              Provider "Bank"
           (hidden internals OK)
```

- **Observable State**: Messages + tool outputs + decisions (your ledger)
- **Hidden State**: Provider reasoning/KV cache (their internals) 
- **Reconciliation**: Local checkpoints for resumption/debugging
- **Durability**: Durable execution platforms as clearinghouses

This sidesteps the synchronization debate. No need for CRDTs across providers—they're not peers. Just build reliable reconciliation on your side.

## Respecting Both Perspectives

Armin's diagnosis rings true: state matters deeply, current APIs obscure it. Mario's pragmatism guides implementation: manage the observable, ignore the rest.

The banking lens simply offers a different starting point—one where opacity is expected, interfaces are crisp, and reliability comes from client-side discipline rather than provider enlightenment.

Coming from banking→programming, this feels natural. Maybe it resonates for others building agentic systems.

What mental models do you use for LLM state?

---

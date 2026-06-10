# Angular + Vitest Test Creation Guide (for LLMs)

> **Testing Docs Index:**
>
> - **README-TEST-AGENT-GUIDE.md** — This file: recipe book for LLMs writing tests
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — PrimeNG v20+ companion cookbook
> - **README-TEST-GUIDE.md** — Human-facing tour of realworld-angular test patterns
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

## Who This Guide Is For

You are an LLM that has been given a task like: "write tests for this Angular + Vitest codebase." This guide is your reference. It does **not** assume any specific project — every recipe is a template with `<substitution>` placeholders. The codebase under test provides the actual code.

This guide does **not** serve humans learning what the realworld-angular project tests. Humans should read `README-TEST-GUIDE.md` instead.

## How to Use This Guide

1. **Pre-flight** — confirm the project setup (see §1).
2. **Identify the file under test** — match its type to the decision tree (§2).
3. **Jump to the recipe** — each per-unit section in §3 follows the same 5-block template.
4. **Substitute placeholders** — `<ServiceClassName>`, `<relative-path>`, etc. are replaced from the source.
5. **Verify** — every recipe's "Common Variants" and "Pitfalls" sections list the most common LLM errors. Read them before writing.

## Universal "Always" List

Every test in this guide assumes these conventions:

- **Vitest globals**: `import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'`. Never use Jasmine's `jasmine.*` or globals.
- **TestBed + signal inputs**: after `fixture.componentRef.setInput(...)`, call `await fixture.whenStable()` before asserting on the DOM.
- **HTTP tests**: `httpTesting.verify()` in `afterEach` to catch un-flushed requests.
- **Reactive graphs**: `TestBed.flushEffects()` after every signal mutation that may trigger an effect.
- **Substitutions**: this guide uses `<placeholder>` syntax. Replace with values from the source file.

## Table of Contents

- [§1. Pre-flight Checks](#1-pre-flight-checks)
- [§2. Decision Tree](#2-decision-tree)
- [§3. Per-Unit Recipes](#3-per-unit-recipes)
- [§4. Cross-Cutting Concerns](#4-cross-cutting-concerns)
- [§5. PrimeNG Components](#5-primeng-components)
- [§6. Common Mistakes Appendix](#6-common-mistakes-appendix)
- [§7. Quick Reference Table](#7-quick-reference-table)

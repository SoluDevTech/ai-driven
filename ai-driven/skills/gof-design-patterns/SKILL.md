---
name: gof-design-patterns
description: "Knowledge base from \"Design Patterns: Elements of Reusable Object-Oriented Software\" by Gamma, Helm, Johnson & Vlissides (GoF). Use when applying GoF patterns (creational, structural, behavioral), choosing between patterns, studying the book, or referencing its concepts."
---

<!-- argument-hint: [topic, pattern name, or chapter number] -->

# Design Patterns: Elements of Reusable Object-Oriented Software
**Author**: Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides ("Gang of Four") | **Pages**: ~417 | **Chapters**: 6 (23 patterns) | **Generated**: 2026-09-18

## How to Use This Skill

- **Without arguments** — load core frameworks for reference
- **With a pattern name** — ask about `Singleton`, `Visitor`, `Bridge`...; I find and read the relevant chapter
- **With a problem** — describe what varies in your design; I apply the selection decision rules from the cheatsheet
- **With chapter** — ask for `ch03`; I load that specific chapter
- **Browse** — ask "what chapters do you have?" to see the full index

When you ask about a topic not covered in Core Frameworks below, I will read
the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

**The two organizing principles of the whole book:**
1. **Program to an interface, not an implementation** — clients commit to abstract classes; factories create the concrete ones.
2. **Favor object composition over class inheritance** — run-time, black-box reuse beats compile-time, white-box reuse. Inheritance leaks parent internals; composition doesn't.

**The master selection heuristic** — *encapsulate the concept that varies*. Identify the axis of change in your design; the pattern that encapsulates that axis is the candidate:

- What varies in *creation* → Abstract Factory (families), Factory Method (subclass), Prototype (instance), Builder (construction process), Singleton (count).
- What varies in *structure* → Adapter (interface), Bridge (implementation), Composite (part-whole), Decorator (responsibilities), Facade (subsystem interface), Flyweight (storage), Proxy (access).
- What varies in *behavior* → Strategy (algorithm), State (state-dependent behavior), Command (request as data), Memento (state snapshots), Observer (dependents), Mediator (peer interaction), Iterator (traversal), Visitor (operations), Chain of Responsibility (handler), Template Method (steps), Interpreter (grammar).

**Key disambiguations the book insists on:**
- **Adapter vs Bridge**: Adapter fixes an interface mismatch after the fact; Bridge is designed up-front so two axes vary independently.
- **Decorator vs Proxy vs Composite**: same structure, different intent — Decorator adds behavior, Proxy controls access, Composite aggregates children.
- **Strategy vs State**: Strategy is stateless and interchangeable; State knows its transitions.
- **Visitor's price**: easy to add operations, expensive to add element classes. Only when the structure is stable.
- **Template Method = inversion of control**: "don't call us, we'll call you" — the base class drives, subclasses hook in.

**Anti-pattern stance (Ch 1.8)** — *never apply patterns indiscriminately*: patterns buy flexibility with indirection; apply only when that flexibility is actually needed. The Consequences sections are the real content of every pattern.

**Pattern description template (13 sections)**: Name / Intent / Also Known As / Motivation / Applicability / Structure / Participants / Collaborations / Consequences / Implementation / Sample Code / Known Uses / Related Patterns — use it to document your own patterns.

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-introduction.md) | Introduction | program-to-interface, composition-over-inheritance, pattern template, MVC example |
| [ch02](chapters/ch02-case-study-lexi.md) | Case Study: Lexi document editor | Composite, Strategy, Decorator, Abstract Factory, Bridge, Command, Visitor — forces-first reasoning |
| [ch03](chapters/ch03-creational.md) | Creational Patterns | Abstract Factory, Builder, Factory Method, Prototype, Singleton |
| [ch04](chapters/ch04-structural.md) | Structural Patterns | Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy |
| [ch05](chapters/ch05-behavioral.md) | Behavioral Patterns | Chain of Responsibility, Command, Interpreter, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor |
| [ch06](chapters/ch06-conclusion.md) | Conclusion | common vocabulary, refactoring targets, expansion/consolidation cycle |

## Topic Index

- **Abstract Factory** → ch03 (case study: ch02)
- **Adapter** → ch04
- **Builder** → ch03
- **Chain of Responsibility** → ch05
- **Command** → ch05 (case study: ch02)
- **Composition vs inheritance** → ch01, ch06
- **Composite** → ch04 (case study: ch02)
- **Decorator** → ch04 (case study: ch02)
- **Delegation** → ch01
- **Double dispatch** → ch05 (Visitor)
- **Facade** → ch04
- **Factory Method** → ch03
- **Flyweight** → ch04
- **Framework design / inversion of control** → ch01, ch05
- **Interpreter** → ch05
- **Iterator** → ch05 (case study: ch02)
- **Mediator** → ch05
- **Memento** → ch05
- **MVC** → ch01
- **Observer** → ch05
- **Prototype** → ch03
- **Proxy** → ch04
- **Refactoring toward patterns** → ch06
- **Selection of a pattern** → ch01 (1.7), cheatsheet
- **Singleton** → ch03
- **State** → ch05
- **Strategy** → ch05 (case study: ch02)
- **Template Method** → ch05
- **Undo** → ch02, ch05 (Command, Memento)
- **Visitor** → ch05 (case study: ch02)

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions
- [patterns.md](patterns.md) — all 23 patterns: when / how / trade-offs
- [cheatsheet.md](cheatsheet.md) — decision rules, disambiguation tables, smells

---

## Scope & Limits

This skill covers the book content only (code examples are modernized Python renditions of the book's C++/Smalltalk idioms, as requested). For hands-on implementation in your codebase, combine with project-specific tools. Note the book predates generics-first languages, functional composition, and concurrency patterns — modern idioms may supersede some implementations (e.g. Singleton) while the *forces* and *intents* remain valid.

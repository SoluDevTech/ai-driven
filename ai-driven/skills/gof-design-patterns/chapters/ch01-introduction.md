# Chapter 1: Introduction

## Core Idea
Design patterns are named, reusable solutions to recurring design problems — they capture expert OO design knowledge so you can communicate at a higher level than code, and they rely on two organizing principles: **program to an interface, not an implementation** and **favor object composition over class inheritance**.

## Frameworks Introduced
- **Program to an interface, not an implementation**: declare variables only in terms of abstract classes/interfaces.
  - When to use: always — inheritance exposes parent details, breaking encapsulation.
  - How: clients stay unaware of concrete classes; objects are created by factories so clients commit only to an interface.
- **Favor object composition over class inheritance**: compose behaviors at run-time instead of hard-coding them via subclassing.
  - When to use: whenever flexibility under change matters.
  - How: delegate to composed objects; inheritance is white-box reuse, composition is black-box reuse.
- **Design pattern description template** (1.3): Pattern Name and Classification / Intent / Also Known As / Motivation / Applicability / Structure / Participants / Collaborations / Consequences / Implementation / Sample Code / Known Uses / Related Patterns.
  - Use this as a checklist when documenting your own patterns.

## Key Concepts
- **Design pattern**: a named description of a problem and solution general enough to apply repeatedly, in a context.
- **Inheritance vs composition**: inheritance (white-box, compile-time, static) vs composition (black-box, run-time, dynamic).
- **Delegation**: two objects involved in handling a request; receiver forwards to a delegate. Makes composition as powerful as inheritance.
- **Parameterized types (generics)**: a third technique (not always OO) — compile-time, no dynamic binding cost, but can't change at run-time.
- **Reuse mechanisms**: white-box reuse (inheritance) vs black-box reuse (composition) vs framework reuse (hooks, inversion of control).

## Mental Models
- Think of patterns as **vocabulary**, not recipes: "Let's use an Observer here" transmits an entire design decision in three words.
- Think of a pattern as **a thing that varies encapsulated**: identify what changes in your system, encapsulate it.
- Frameworks = semi-complete applications; patterns = smaller, more abstract elements that frameworks embody.

## Anti-patterns
- **Applying patterns indiscriminately**: patterns add indirection — costs complexity and performance. Apply only when the flexibility is actually needed.
- **Overusing inheritance for reuse**: fragile — parent details leak to children; changes in parent ripple to children.
- **Confusing patterns with frameworks or libraries**: patterns are language-independent design knowledge, not code you install.

## Reference Tables
Catalog organization (purpose × scope):

| | Creational | Structural | Behavioral |
|---|---|---|---|
| Class | Factory Method | Adapter (class) | Interpreter, Template Method |
| Object | Abstract Factory, Builder, Prototype, Singleton | Adapter (object), Bridge, Composite, Decorator, Facade, Flyweight, Proxy | Chain of Responsibility, Command, Iterator, Mediator, Memento, Observer, State, Strategy, Visitor |

## Worked Example
MVC (Smalltalk) read as three patterns collaborating: **Observer** (Model notifies Views of state changes), **Composite** (nested Views), **Strategy** (Controller as the View's strategy for handling input). MVC decouples views from models by establishing a subscribe/notify protocol — the model needs no knowledge of its views.

## Key Takeaways
1. Identify what varies in your design and encapsulate it — this is the root rationale of most patterns.
2. Program to an interface: clients commit to abstract classes, not concrete ones.
3. Favor composition: run-time reconfiguration beats compile-time inheritance chains.
4. Use the 13-section pattern template when documenting design knowledge.
5. Patterns are a design vocabulary — name them in discussions, reviews, and docs.

## Connects To
- **Ch 3-5**: the catalog itself, organized by purpose (creational/structural/behavioral).
- **Ch 6**: patterns as refactoring targets and shared vocabulary.
- **MVC**: the canonical case study of pattern collaboration.

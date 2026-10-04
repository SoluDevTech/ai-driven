# Cheatsheet — Design Patterns (GoF)

## Selection decision rules

**Start from what varies, not from the pattern:**
- What varies → pattern that encapsulates it:
  - *how objects are created / which family* → Abstract Factory, Factory Method, Prototype, Builder
  - *interface mismatches* → Adapter
  - *abstraction vs implementation axes* → Bridge
  - *part-whole structure* → Composite
  - *responsibilities added dynamically* → Decorator
  - *subsystem complexity / coupling* → Facade
  - *memory of many small objects* → Flyweight
  - *access control / lazy / remote* → Proxy
  - *who handles a request* → Chain of Responsibility
  - *requests as data (undo, queues, macros)* → Command
  - *a small language* → Interpreter
  - *traversal order / polymorphic iteration* → Iterator
  - *peer-to-peer interaction spaghetti* → Mediator
  - *undoable state snapshots* → Memento
  - *dependents of a changing object* → Observer
  - *behavior driven by state* → State
  - *interchangeable algorithm* → Strategy
  - *invariant skeleton + variant steps* → Template Method
  - *new operations on a stable structure* → Visitor

**Disambiguation rules:**
| If you see… | Choose | Not |
|---|---|---|
| Incompatible existing interface | Adapter | Bridge (Bridge is designed up-front) |
| "Add X to Y" with nesting needed | Decorator | Subclassing per combination |
| Need to wrap children + uniform handling | Composite | Decorator (one child, adds behavior) |
| Same structure, "control access" intent | Proxy | Decorator (adds behavior) |
| Behavior + transitions between behaviors | State | Strategy (stateless, no transitions) |
| Subclasses decide *what* gets created | Factory Method | Abstract Factory (families of products) |
| Object built step-by-step, returned at end | Builder | Factory Method (returns immediately) |
| Stable structure, churning operations | Visitor | Composite methods on every class |
| One handler unknown in advance | Chain of Responsibility | Mediator (coordinates, doesn't pass) |
| Centralized interaction *rules* among peers | Mediator | Observer (event broadcast) |

## Trade-off matrix (quick scan)

| Constraint | Best fit | Acceptable |
|---|---|---|
| Run-time flexibility first | Strategy, Decorator, Bridge | Prototype |
| Minimal object count | Template Method | Facade |
| Undo/redo required | Command (+ Memento) | — |
| Memory of millions of objects | Flyweight | — |
| Tests hate globals | avoid Singleton; inject factories | — |
| New element types frequent | Composition/Iterator | never Visitor |
| New operations frequent | Visitor | — |

## Thresholds & defaults
- Apply a pattern **only when its flexibility is actually needed** — patterns add indirection that costs complexity and performance (Ch 1.8).
- One **ConcreteFactory instance per product family** — implement factories as Singletons.
- **Object Adapter > Class Adapter** — prefer composition; multiple inheritance only when unavoidable.
- **Deep copy** in Prototype Clone for composite objects; shallow copy only for immutable parts.
- Undo needs **every command to store enough state** to reverse itself — or capture a Memento before executing.
- MacroCommand undo runs **in reverse order**.

## Tells & smells
- `if/elif` chains selecting behavior or handling states → Strategy / State.
- Classes named `XxxManager` doing everything → Facade or Mediator missing.
- Subclass explosion (`AwithBwithC`) → Decorator.
- Clients `new`-ing concrete classes everywhere → Factory Method / Abstract Factory.
- "I need undo but I'd have to expose internals" → Memento.
- "New requirement = new method in 15 classes" → Visitor (only if the structure is stable).
- Two parallel class hierarchies kept in sync by hand → Bridge.
- Traversal logic duplicated per collection → Iterator.

## Applying a pattern (Ch 1.8, condensed)
1. Read Intent + Applicability + Consequences — is it the right problem?
2. Study Structure, Participants, Collaborations.
3. Check Sample Code for implementation hints.
4. Name participants after the pattern in context (e.g. `SimpleLayoutStrategy`).
5. Define classes, interfaces, instance variables.
6. Name operations app-specific but conventionally (e.g. `Create-` prefix for factory methods).
7. Implement per responsibilities/collaborations; guided by the Implementation section.

## Catalog at a glance (intent one-liners)
- **Abstract Factory** — families of related objects without concrete classes.
- **Builder** — same construction process, different representations.
- **Factory Method** — subclasses decide which class to instantiate.
- **Prototype** — create by cloning a prototypical instance.
- **Singleton** — one instance, global access point.
- **Adapter** — make incompatible interfaces work together.
- **Bridge** — abstraction and implementation vary independently.
- **Composite** — part-whole trees, uniform treatment.
- **Decorator** — attach responsibilities dynamically, flexible subclassing alternative.
- **Facade** — one simple interface over a subsystem.
- **Flyweight** — sharing for masses of fine-grained objects.
- **Proxy** — surrogate controlling access to another object.
- **Chain of Responsibility** — request along a chain until handled.
- **Command** — request as an object: parameterize, queue, log, undo.
- **Interpreter** — grammar as classes, interpret sentences.
- **Iterator** — sequential access without exposing representation.
- **Mediator** — encapsulate how peers interact.
- **Memento** — capture/restore state without violating encapsulation.
- **Observer** — one-to-many change notification.
- **State** — behavior changes with internal state.
- **Strategy** — interchangeable family of algorithms.
- **Template Method** — algorithm skeleton, steps deferred to subclasses.
- **Visitor** — new operations without changing element classes.

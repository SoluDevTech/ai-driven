# Chapter 6: Conclusion

## Core Idea
Design patterns' main value is a **common design vocabulary**: they let designers communicate, document, and refactor at a higher level of abstraction — and they are an adjunct to design methods, not a complete method themselves.

## Frameworks Introduced
- **What patterns give you** (6.1):
  - *A common design vocabulary* — "Let's use an Observer here" carries a whole design decision.
  - *A documentation and learning aid* — patterns make existing systems decodable instead of requiring reverse engineering.
  - *An adjunct to existing methods* — patterns capture the "why" of design decisions that methods (notations + rules) miss.
  - *A target for refactoring* — patterns are the destinations of refactorings; applying them early prevents later refactors.
- **Software lifecycle phases** (Brian Foote): prototyping → expansionary (requirements pile on, hierarchies bloat) → consolidating (refactoring: decompose classes, swap inheritance for composition, white-box → black-box reuse). The expansion/consolidation cycle is unavoidable; patterns are how good designers ride it.
- **Alexander's pattern language contrast** (6.3): GoF patterns describe *solutions* in detail; Alexander's patterns emphasize *problems*, have an order, and claim to generate complete buildings — the GoF catalog is explicitly **not** a complete pattern language for software.

## Key Concepts
- **Pattern vs method**: a method tells you *when* and *in what order*; patterns supply named solutions to recurring forces within any method.
- **Refactoring toward patterns**: design patterns capture structures that result from refactoring; they serve as both prevention and destination.
- **Pattern community origins**: Christopher Alexander's architecture (A Pattern Language), Coplien's C++ idioms, PLoP conferences.

## Mental Models
- "Patterns raise the abstraction level of design talk" — from classes and methods to forces and intents.
- "Software breathes between expansion and consolidation" — reuse needs force refactoring; patterns are consolidation targets.
- Finding a pattern is easy; *describing* it (problem + forces + trade-offs) is the hard part.

## Anti-patterns
- **Expecting patterns to be a step-by-step design method**: the catalog is a collection, not an ordered generative language.
- **Believing analysis models map smoothly to designs**: implementation constraints (language, libraries) force redesign — patterns address exactly that gap.
- **Ignoring trade-offs in pattern write-ups**: Applicability, Consequences, and Implementation sections are the pattern's real content.

## Worked Example
The history of the catalog itself (6.2): patterns renamed as they matured (Wrapper→Decorator, Glue→Facade, Solitaire→Singleton, Walker→Visitor); patterns grew from 2-page sketches to 10-page treatments with motivation, sample code, and trade-offs once the authors realized that *describing the problem* matters more than describing the solution. Lesson: a pattern without its problem statement and consequences is just a code recipe.

## Key Takeaways
1. Use the vocabulary — say "Strategy" and "Observer" in design discussions, reviews, and docs.
2. Treat patterns as refactoring targets: know where your design *can* go as requirements grow.
3. A pattern description must capture the problem and forces, not only the solution.
4. The catalog is incomplete by design — software will never have one total pattern language.
5. Be a critical consumer: patterns are explicit, arguable trade-offs, not gospel.

## Connects To
- **Ch 1**: the two principles (interface programming, composition) that the whole catalog applies.
- **Ch 3-5**: the 23 patterns this chapter situates historically.
- **Christopher Alexander**: the architectural origin of the pattern movement.

# Chapter 2: A Case Study — Lexi (Document Editor)

## Core Idea
Seven real design problems in a document editor (Lexi) are each solved by a pattern — demonstrating that patterns emerge from concrete forces (constraints and trade-offs), not from abstract elegance.

## Frameworks Introduced
- **Design problem → forces → pattern** reasoning: enumerate constraints (encapsulation, consistency, extensibility, performance), then pick the pattern that resolves them.
- **Document structure = Composite**: recursive composition of Glyphs (rows, characters, pictures).
  - How: abstract class Glyph with Draw() and Bounds(); children compose arbitrarily.
- **Formatting as Strategy**: linebreaking algorithms (simple greedy, TeX) are interchangeable strategies owned by a Compositor.
- **Embellishments as Decorator**: borders and scrollbars wrap a Glyph transparently; nested decorators compose.
- **Multiple look-and-feel / window systems**: Abstract Factory (widget kits per GUI standard) + Bridge (Window abstraction decoupled from WindowImp implementation).
- **User operations as Command**: menu items are Command objects → undo/redo via unexecute(), macro commands via composition.
- **Spell-check/hyphenation as Visitor**: traversal + analysis separated from Glyph structure; each analysis is a Visitor over the glyph tree.

## Key Concepts
- **Glyph**: abstract Lexi primitive (character, row, image) — uniform interface for structure.
- **Compositor**: encapsulates the linebreaking algorithm (Strategy).
- **WindowImp**: platform-specific window implementation hidden behind a Window interface (Bridge).
- **Iterator**: abstracts traversal over glyph children (internal/external iterators).
- **BoundedPointers / Memento-style history**: supporting undo of arbitrary commands requires storing state snapshots.

## Mental Models
- "Use X when Y" summary of Ch2 decisions:
  - Recursive part-whole structures → Composite
  - Interchangeable algorithms → Strategy
  - Transparent add-on responsibilities → Decorator
  - Families of related widgets → Abstract Factory
  - Abstract vs implementation axes varying → Bridge
  - Undoable/macro-able requests → Command
  - Operations over a stable structure → Visitor

## Anti-patterns
- **Hard-coding look-and-feel classes throughout the app**: makes porting cost explode — route creation through factories.
- **Baking the algorithm into the aggregate**: formatting inside Glyph classes makes algorithms unchangeable — encapsulate as Strategy.
- **Extending every class for a new operation (e.g. spell-check)**: explodes class count and breaks encapsulation — use Visitor instead.

## Reference Tables

| Design problem | Forces | Pattern |
|---|---|---|
| Document structure | recursive composition, uniform treatment | Composite |
| Formatting | algorithm must vary | Strategy |
| Embellishment | transparent, nested extras | Decorator |
| Multiple look-and-feels | families must stay consistent | Abstract Factory |
| Multiple window systems | abstraction & impl vary independently | Bridge |
| User operations | undo, macros, multiple UI entries | Command |
| Spell check & hyphenation | new ops on stable structure | Visitor (+ Iterator for traversal) |

## Worked Example
Undo via Command: a menu item holds a Command. `Execute()` performs and stores the command on a history list; `Unexecute()` reverses it. Un-creatable operations (e.g. a paste whose affected glyphs were deleted) require the command to save affected state — leading toward Memento. A MacroCommand is simply a Command that executes child commands — Composite applied to Command.

## Key Takeaways
1. Patterns answer concrete engineering tensions, not style preferences.
2. One feature (undo) can ripple across patterns: Command → history → Memento.
3. The same case study reuses 8+ patterns interlocking — real designs are pattern *weaves*.
4. When a structure is stable and operations keep arriving, reach for Visitor; when operations are stable and structure varies, reach for Composite/Decorator.

## Connects To
- **Ch 3**: Abstract Factory, Singleton details.
- **Ch 4**: Composite, Decorator, Bridge, Facade details.
- **Ch 5**: Command, Iterator, Visitor details.

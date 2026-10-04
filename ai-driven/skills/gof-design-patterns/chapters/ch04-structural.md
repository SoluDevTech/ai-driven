# Chapter 4: Structural Patterns

## Core Idea
Structural patterns compose classes and objects into larger structures — class patterns use inheritance to mix interfaces, object patterns compose objects at run-time to gain flexibility that static inheritance can never offer.

## Frameworks Introduced
- **Adapter** (a.k.a. Wrapper) — *Convert the interface of a class into another interface clients expect. Adapter lets classes work together that couldn't otherwise because of incompatible interfaces.*
  - When: you want to use an existing class whose interface doesn't match what you need; or unify several unrelated subclasses.
  - How: Class Adapter inherits the adaptee privately and expresses Target in terms of it; Object Adapter composes the adaptee and delegates.
  - Trade-offs: object adapter lets one adapter serve many adaptees (incl. subclasses); class adapter needs multiple inheritance and can't adapt subclasses.
- **Bridge** — *Decouple an abstraction from its implementation so that the two can vary independently.*
  - When: you'd otherwise have a class explosion (PlatformWindow × Shape) or want to swap implementations at run-time.
  - How: Abstraction holds a reference to an Implementor interface; RefinedAbstractions and ConcreteImplementors vary on independent axes.
  - Trade-offs: eliminates permanent binding, hides implementation details from clients; adds one indirection level.
- **Composite** — *Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly.*
  - When: part-whole hierarchies; clients should ignore leaf vs composite difference.
  - How: common abstract Component (Glyph); Leaf and Composite both implement Component; Composite delegates to children.
  - Trade-offs: uniform client code, easy to add new component kinds — but can make the design overly general and hard to constrain.
- **Decorator** — *Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality.*
  - When: subclassing for every responsibility combination explodes; responsibilities must be added/removed at run-time.
  - How: Decorator conforms to the Component interface, holds a Component, forwards messages, does its work before/after.
  - Trade-offs: more flexible than inheritance — but a decorated object is not identical to its component (identity tests fail), and many tiny objects.
- **Facade** — *Provide a unified interface to a set of interfaces in a subsystem. Facade defines a higher-level interface that makes the subsystem easier to use.*
  - When: clients need a simple entry point; layering subsystems; coupling must be reduced.
  - How: Facade forwards requests to subsystem objects; subsystem doesn't know the facade; clients may still bypass it.
  - Trade-offs: shields clients, weakens coupling — but it risks becoming a god object; it doesn't prevent advanced clients from going direct.
- **Flyweight** — *Use sharing to support large numbers of fine-grained objects efficiently.*
  - When: millions of fine-grained objects (characters in a document, trees in a map); memory is the constraint.
  - How: split intrinsic (shared, immutable) vs extrinsic (contextual, passed in) state; a FlyweightFactory manages and shares instances.
  - Trade-offs: massive space savings — but run-time cost of passing extrinsic state; only works if state truly splits.
- **Proxy** — *Provide a surrogate or placeholder for another object to control access to it.*
  - When: lazy loading (virtual), remote access (remote), access control (protection), copy-on-write (smart reference).
  - How: Proxy holds a reference to RealSubject, implements the same interface, controls access on every call.
  - Trade-offs: indirection with zero client changes — but overhead per call; compare with Decorator (same structure, different intent).

## Key Concepts
- **Adapter vs Bridge**: Adapter fixes an *after-the-fact* interface mismatch; Bridge is designed *up front* so abstraction and implementation vary independently.
- **Decorator vs Composite**: Decorator adds responsibilities (one child, no aggregation semantics); Composite aggregates (many children).
- **Decorator vs Proxy**: same structure, different intent — Decorator adds behavior, Proxy controls access.
- **Flyweight sharing**: objects are shareable only if they have no context-dependent state.
- **Facade vs Adapter**: Facade simplifies a subsystem's *many* interfaces to one; Adapter gives one existing interface a new one.

## Mental Models
- "Think of Bridge as a plug and socket": abstractions plug into swappable implementations.
- "Decorator = Russian dolls": each wrapper conforms to the wrapped interface and forwards, adding work before/after.
- "Flyweight = character in a text editor": one shared 'a' glyph object, position passed in per use.
- "Facade = concierge": one desk that routes your requests into a complex subsystem.

## Anti-patterns
- **Class-explosion via inheritance for every feature combo**: `BorderedScrollableTextArea`, `ScrollableTextArea`, ... → use Decorator.
- **Deep inheritance to mix two library interfaces**: → use Object Adapter (composition) instead of multiple inheritance.
- **Facade that absorbs business logic**: keep the facade thin — it forwards and simplifies, it doesn't own policy.
- **Applying Flyweight without a clean intrinsic/extrinsic split**: sharing breaks when hidden state differs.

## Code Examples
Object Adapter (Python idiom):
```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def bounding_box(self) -> "Rect": ...
    @abstractmethod
    def draw(self, request: "DrawRequest") -> None: ...

class TextView:  # existing, unrelated class
    def get_extent(self) -> tuple[int, int]: ...
    def draw_at(self, x: int, y: int) -> None: ...

class TextShape(Shape):  # Object Adapter
    def __init__(self, text_view: TextView) -> None:
        self._text_view = text_view
    def bounding_box(self) -> Rect:
        w, h = self._text_view.get_extent()
        return Rect(0, 0, w, h)
    def draw(self, request: DrawRequest) -> None:
        self._text_view.draw_at(request.x, request.y)
```
- **What it demonstrates**: composition + delegation adapts `TextView` to `Shape` without touching either.

Bridge (Python idiom):
```python
class WindowImp(ABC):  # implementor axis
    @abstractmethod
    def dev_draw_text(self, text: str) -> None: ...
    @abstractmethod
    def dev_draw_line(self, x1: int, y1: int, x2: int, y2: int) -> None: ...

class XWindowImp(WindowImp): ...   # X11 specifics
class PMWindowImp(WindowImp): ...  # Presentation Manager specifics

class Window:  # abstraction axis
    def __init__(self, imp: WindowImp) -> None:
        self._imp = imp
    def draw_text(self, text: str) -> None:
        self._imp.dev_draw_text(text)
    def draw_rect(self, x1, y1, x2, y2) -> None:
        for a, b in self._corners(x1, y1, x2, y2):
            self._imp.dev_draw_line(*a, *b)  # abstract uses concrete

class IconWindow(Window):  # refined abstraction
    def draw(self) -> None: self._imp.dev_draw_text("icon")
```
- **What it demonstrates**: Abstraction and Implementor vary on two independent axes — no PlatformWindow explosion.

Composite + Decorator (Python idiom, from the Lexi case study):
```python
class Glyph(ABC):
    @abstractmethod
    def draw(self, w: "Window") -> None: ...
    @abstractmethod
    def bounds(self) -> "Rect": ...

class Character(Glyph):  # leaf
    def __init__(self, char: str) -> None: self._char = char
    def draw(self, w): w.draw_text(self._char)
    def bounds(self): return SMALL_RECT

class Row(Glyph):  # composite
    def __init__(self, children: list[Glyph]) -> None:
        self._children = children
    def draw(self, w):
        for child in self._children:
            child.draw(w)
    def bounds(self):
        return union(c.bounds() for c in self._children)

class Border(Glyph):  # decorator
    def __init__(self, component: Glyph, width: int = 1) -> None:
        self._component, self._width = component, width
    def draw(self, w):
        self._component.draw(w)          # forward
        w.draw_rect(*self._border_rect())  # then add responsibility
    def bounds(self):
        return grow(self._component.bounds(), self._width)
```
- **What it demonstrates**: uniform Glyph interface; `Border(Text(Row(...)))` nests transparently.

Flyweight (Python idiom):
```python
class GlyphFactory:
    _cache: dict[str, "Character"] = {}
    def get_character(self, char: str) -> "Character":
        if char not in self._cache:
            self._cache[char] = Character(char)  # intrinsic state only
        return self._cache[char]

# extrinsic state (position) passed per use — never stored on the glyph:
glyph = factory.get_character("a")
glyph.draw(window, at=Point(x=12, y=3))
```
- **What it demonstrates**: one shared 'a' object serves millions of uses; context travels as parameters.

Facade (Python idiom):
```python
class CompilerFacade:
    """Unifies Scanner, Parser, ProgramNodeBuilder, BytecodeStream."""
    def compile(self, source: str) -> "Bytecode":
        tokens = Scanner(source).scan()
        tree = Parser(ProgramNodeBuilder()).parse(tokens)
        return BytecodeStream(tree).to_bytecode()

client_code = CompilerFacade().compile("int main() {}")
# the subsystem classes remain usable directly by power users
```
- **What it demonstrates**: one high-level entry point over many subsystem interfaces.

Proxy (Python idiom):
```python
class Graphic(ABC):
    @abstractmethod
    def draw(self, at: Point) -> None: ...

class ImageProxy(Graphic):  # virtual proxy — lazy load
    def __init__(self, path: str) -> None:
        self._path, self._image = path, None
    def draw(self, at: Point) -> None:
        if self._image is None:
            self._image = load_huge_image(self._path)  # on demand
        self._image.draw(at)
```
- **What it demonstrates**: placeholder defers the expensive construction until first use.

## Reference Tables

| Pattern | Aspect that can vary | Key trade-off |
|---|---|---|
| Adapter | interface to an object | post-hoc fix vs up-front design |
| Bridge | implementation of an object | two variation axes, one indirection |
| Composite | structure and composition of an object | uniformity vs over-generality |
| Decorator | responsibilities of an object without subclassing | flexible but identity-breaking |
| Facade | interface to a subsystem | simplifies, risks god object |
| Flyweight | storage costs of objects | space saved, state-passing cost |
| Proxy | how an object is accessed; its location | control vs per-call overhead |

## Worked Example
The GoF drawing editor: `TextShape` (Adapter) wraps `TextView` so a text object becomes a drawable Shape; the editor window uses Bridge so the same shapes render on X or PM; the document is a Composite of Glyphs; borders/scrollbars are Decorators around glyphs; the character store uses Flyweight. One app, five structural patterns, each solving a distinct axis of change.

## Key Takeaways
1. Structural object patterns beat class patterns: composition varies at run-time, inheritance doesn't.
2. Bridge *before* the explosion, Adapter *after* the mismatch.
3. Decorator and Proxy share structure — distinguish by intent (add behavior vs control access).
4. Flyweight requires a strict intrinsic/extrinsic state split.
5. Facade weakens coupling but must stay thin.

## Connects To
- **Ch 2**: Composite, Decorator, Bridge in the Lexi case study.
- **Ch 3**: Factories often produce the Flyweights/Proxies.
- **Ch 5**: Iterator traverses Composite structures.

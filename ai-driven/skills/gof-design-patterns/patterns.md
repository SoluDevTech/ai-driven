# Patterns — Design Patterns (GoF)

## Creational

### Abstract Factory
**When to use**: a system must be configured with one of multiple families of products; family members must be used together; you want to expose interfaces, not implementations.
**How**: AbstractFactory declares one creation operation per abstract product; one ConcreteFactory per family; clients use only abstract interfaces. Implement factories as singletons; produce products via factory methods or prototypes.
**Trade-offs**: isolates concrete classes, swaps whole families, enforces consistency — but adding a new product *kind* requires changing the factory interface and all subclasses.

### Builder
**When to use**: the construction algorithm of a complex object is independent of its parts and their assembly; the same steps must yield different representations.
**How**: Director executes build steps on a Builder interface; ConcreteBuilder assembles internals and returns the product only at the end (GetResult).
**Trade-offs**: precise control over construction, representation can change — but a distinct builder per representation.

### Factory Method
**When to use**: a class can't anticipate which objects it must create; framework users must specialize internals; parallel class hierarchies need hooks.
**How**: Creator declares the factory method; ConcreteCreator overrides it. Clients call the factory method instead of `new`.
**Trade-offs**: decouples clients from concrete classes — but may force clients to subclass the Creator just to instantiate.

### Prototype
**When to use**: run-time instantiation of classes unknown statically; avoiding factory-class proliferation; only a few state/structure combos exist.
**How**: each class implements Clone() (deep copy for composites); a client (or prototype registry) clones registered prototypes.
**Trade-offs**: hides concrete classes, adds/removes products at run-time — but every class needs Clone; circular references need care.

### Singleton
**When to use**: exactly one instance must exist (factories, window managers) and it must be globally accessible.
**How**: hide the constructor; static Instance() with lazy creation; registry of singletons for open-ended cases; subclass support via explicit registry keys.
**Trade-offs**: controlled access, per-subclass instances — but it is effectively a global variable and complicates testing.

## Structural

### Adapter (Wrapper)
**When to use**: an existing class's interface doesn't match what clients need; you must unify several unrelated subclasses.
**How**: Class Adapter inherits the adaptee; Object Adapter composes it and delegates. Prefer the object form.
**Trade-offs**: enables reuse of unrelated classes — but the object adapter can't override adaptee behavior without subclassing it.

### Bridge
**When to use**: abstraction and implementation axes must vary independently; avoid a class explosion of combinations; swap implementations at run-time.
**How**: Abstraction holds an Implementor reference; RefinedAbstractions and ConcreteImplementors evolve independently.
**Trade-offs**: eliminates permanent binding, hides implementation details — adds one indirection level.

### Composite
**When to use**: part-whole hierarchies; clients should treat primitives and compositions uniformly.
**How**: common Component interface; Leaf and Composite implement it; Composite forwards to children (with child management ops on the Component or Composite).
**Trade-offs**: uniform client code, easy extension — but can over-generalize the design and make constraints hard to enforce.

### Decorator
**When to use**: add/remove responsibilities dynamically; subclassing for every combination explodes.
**How**: Decorator implements the Component interface, holds a Component, forwards messages, adds work before/after.
**Trade-offs**: more flexible than inheritance — breaks object identity, produces many tiny objects.

### Facade
**When to use**: a simple entry point into a subsystem; layer subsystems; reduce coupling.
**How**: Facade forwards requests to subsystem objects; subsystem classes stay usable directly by advanced clients.
**Trade-offs**: shields clients, weakens coupling — risks becoming a god object if it absorbs policy.

### Flyweight
**When to use**: huge numbers of fine-grained objects; memory is the bottleneck.
**How**: split intrinsic (shared) vs extrinsic (passed-in) state; FlyweightFactory caches and shares instances.
**Trade-offs**: massive space savings — run-time cost of passing extrinsic state; impossible without a clean state split.

### Proxy
**When to use**: lazy loading (virtual proxy), remote objects (remote proxy), access control (protection proxy), copy-on-write (smart reference).
**How**: Proxy implements the Subject interface, holds a reference to RealSubject, intercepts every call.
**Trade-offs**: transparent indirection — per-call overhead; same structure as Decorator but intent is access control, not added behavior.

## Behavioral

### Chain of Responsibility
**When to use**: more than one object may handle a request; the handler isn't known in advance; chains should be configured at run-time.
**How**: each Handler stores a successor; handleRequest() handles or forwards.
**Trade-offs**: reduced coupling, dynamic chains — requests may go unhandled; hard to debug.

### Command (Action, Transaction)
**When to use**: undo/redo, request queues, logs, macros, menu items triggered from many places.
**How**: execute() on a Command interface; ConcreteCommand binds a Receiver; Invoker triggers; unexecute() or stored state for undo; MacroCommand composes.
**Trade-offs**: first-class, queueable requests — one class per command proliferates.

### Interpreter
**When to use**: a simple, stable language with many sentences to interpret.
**How**: one class per grammar rule; Terminal/Nonterminal expressions with interpret(context).
**Trade-offs**: easy grammar extension — impractical for complex grammars (use parser generators).

### Iterator (Cursor)
**When to use**: traversal must be polymorphic, support multiple simultaneous iterations, or vary in order.
**How**: external iterator (First/Next/IsDone/CurrentItem — or Python's `__iter__`/`next`) vs internal iterator (aggregate drives a passed operation).
**Trade-offs**: decouples aggregate from traversal — exposes traversal state (external) or limits flexibility (internal).

### Mediator
**When to use**: many peers reference each other explicitly; interaction logic must be centralized/parameterized.
**How**: colleagues notify the Mediator; the Mediator coordinates them. Star topology.
**Trade-offs**: decouples peers, localizes interaction — the mediator can become monolithic.

### Memento (Token)
**When to use**: snapshots for undo/checkpoints without exposing internal state.
**How**: Originator creates/uses Mementos; the Caretaker stores them but never inspects them (wide/narrow interfaces).
**Trade-offs**: preserves encapsulation — full snapshots can be expensive; incremental ones cost complexity.

### Observer (Publish-Subscribe)
**When to use**: changes to one object require updating a varying set of dependents (model→views).
**How**: Subject keeps observers; notify() calls update(); observers pull state from the subject.
**Trade-offs**: abstract coupling, broadcast updates — cascades can surprise; observers must detach to avoid dangling references.

### State (Objects for States)
**When to use**: behavior depends on state with sprawling conditionals; state-dependent code is duplicated across operations.
**How**: Context delegates to a State object; transitions happen in the Context or in the states themselves.
**Trade-offs**: localized, explicit state behavior — state object proliferation; table-driven alternatives for pure lookups.

### Strategy (Policy)
**When to use**: related classes differ only in behavior; you need different variants of an algorithm; conditionals select behavior.
**How**: Strategy interface; Context holds and delegates to a Strategy; chosen at run-time.
**Trade-offs**: kills conditional sprawl, offers alternative implementations — clients must know the strategies; more objects.

### Template Method
**When to use**: an invariant algorithm skeleton with variant steps; factor common behavior up the hierarchy; framework hooks.
**How**: a concrete base-class method calls primitive (hook) operations that subclasses override.
**Trade-offs**: reuse + inversion of control ("don't call us, we'll call you") — a subclass per step variant; Strategy composes better.

### Visitor
**When to use**: an object structure is stable but operations on it keep accumulating; related behavior must be centralized; double dispatch is needed.
**How**: each element's accept(visitor) calls visitor.visitConcreteElement(this); one visitX per element class.
**Trade-offs**: easy to add operations, centralized behavior — hard to add element classes; visitors can break element encapsulation.

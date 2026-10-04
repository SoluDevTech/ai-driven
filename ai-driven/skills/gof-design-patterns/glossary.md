# Glossary — Design Patterns (GoF)

**Abstract class** — A class whose primary purpose is to define an interface; defers some or all implementation to subclasses; cannot be instantiated. (Ch 1)

**Abstract coupling** — Class A maintains a reference to abstract class B: A refers to a *type* of object, not a concrete object. (Ch 1)

**Acquaintance relationship** — Looser coupling than aggregation: a class refers to another but doesn't own its lifecycle. (Ch 1)

**Aggregate object** — An object composed of subobjects (parts) for which it is responsible. (Ch 1)

**Black-box reuse** — Reuse by object composition: composed objects reveal no internal details to each other. (Ch 1, Ch 6)

**Class adapter** — Adapter implemented via (multiple) inheritance from the adaptee's class. (Ch 4)

**Class creational pattern** — Varies the class that's instantiated using inheritance (Factory Method, class-scoped). (Ch 3)

**Client** — The participant that uses interfaces declared by abstract classes, never concrete ones. (Ch 3)

**Colleague** — An object that communicates with other colleagues only through a Mediator. (Ch 5)

**Component** — The common interface of leaf and composite objects in a Composite. (Ch 4)

**Composite** — An object composed of child components; forwards requests to children. (Ch 4)

**Concrete factory / concrete product** — The family-specific factory and the objects it creates (Abstract Factory roles). (Ch 3)

**Context** — The class that delegates state- or strategy-dependent behavior to an embedded object (State/Strategy role). (Ch 5)

**Delegation** — Two objects involved in handling a request; the receiver forwards operations to a delegate. Makes composition as powerful as inheritance. (Ch 1)

**Director** — Drives the Builder interface to construct a product step by step. (Ch 3)

**Double dispatch** — Visitor mechanism: element.accept(visitor) calls visitor.visitConcreteElement(this), resolving both types at run-time. (Ch 5)

**Extrinsic state** — Context-dependent state passed to a Flyweight per use, never stored on it. (Ch 4)

**Factory method** — An operation an object calls to instantiate; subclasses override to specify the concrete class. (Ch 3)

**Framework** — A set of cooperating classes making up a reusable design for a specific class of software; provides inversion of control via hooks. (Ch 1)

**Handler** — A participant in Chain of Responsibility; handles a request or forwards it to its successor. (Ch 5)

**Hook operation** — A default (often empty) operation subclasses override to extend a Template Method. (Ch 1, Ch 5)

**Implementation (of an abstraction)** — The implementor object hidden behind a Bridge abstraction; varies independently of it. (Ch 4)

**Intrinsic state** — Shareable, context-independent state stored inside a Flyweight. (Ch 4)

**Invoker** — The object that triggers a Command's execute() (e.g. a menu item). (Ch 5)

**Kit** — "Also known as" name for Abstract Factory. (Ch 3)

**Leaf** — A component with no children in a Composite. (Ch 4)

**Mediator** — The object encapsulating how a set of peers interact; star topology hub. (Ch 5)

**Memento** — A state snapshot produced by the Originator, stored (but never inspected) by the Caretaker. (Ch 5)

**Object creational pattern** — Delegates instantiation to another object via composition (Abstract Factory, Builder, Prototype). (Ch 3)

**Observer** — The dependent object updated by a subject's notify(). (Ch 5)

**Originator** — The object whose state a Memento captures and restores. (Ch 5)

**Parameterized type (generics)** — Compile-time type variation technique, complementary to (not always part of) OO patterns. (Ch 1)

**Pattern (design)** — A named, general, reusable description of a problem and solution within a context. (Ch 1)

**Primitive operation** — A step of a Template Method that subclasses define or override. (Ch 5)

**Prototype** — An object cloned to create new instances. (Ch 3)

**Proxy** — A surrogate holding a reference to the real subject, controlling access to it. (Ch 4)

**Refactoring** — Reorganizing software (tearing apart classes, moving operations up/down hierarchies) without changing behavior. (Ch 6)

**Singleton** — The sole, lazily created, globally accessible instance of a class. (Ch 3)

**Strategy** — An interchangeable encapsulated algorithm held and invoked by a Context. (Ch 5)

**Structural pattern** — Pattern concerned with how classes/objects are composed into larger structures. (Ch 4)

**Subject** — The object watched by observers; sends notify() on state change. (Ch 5)

**Template method** — The base-class method defining an algorithm's skeleton via primitive operations. (Ch 5)

**Visitor** — The object encapsulating an operation performed over an object structure via double dispatch. (Ch 5)

**White-box reuse** — Reuse by inheritance: subclass sees and depends on parent internals. (Ch 1, Ch 6)

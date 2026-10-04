# Chapter 5: Behavioral Patterns

## Core Idea
Behavioral patterns distribute responsibilities and communication between objects — they shift your focus from control flow to object interconnection, encapsulating *behavior* (algorithms, requests, states, traversals) in objects that can vary independently.

## Frameworks Introduced
- **Chain of Responsibility** — *Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it.*
  - When: more than one object may handle a request and the handler isn't known in advance (help systems, middleware).
  - How: each Handler keeps a successor; handleRequest() either handles or forwards.
  - Trade-offs: reduced coupling, flexible chains — but the request may go unhandled, and chains are hard to debug.
- **Command** (a.k.a. Action, Transaction) — *Encapsulate a request as an object, thereby letting you parameterize clients with different requests, queue or log requests, and support undoable operations.*
  - When: undo/redo, queues, logs, macros, menus triggered from many UI points.
  - How: Command interface with execute(); ConcreteCommand binds a Receiver; Invoker triggers; undo via unexecute() or stored state.
  - Trade-offs: first-class requests, composition (MacroCommand) — but one class per command can proliferate.
- **Interpreter** — *Given a language, define a representation for its grammar along with an interpreter that uses the representation to interpret sentences in the language.*
  - When: a simple language recurs; grammar is stable; sentences are plentiful.
  - How: one class per grammar rule; TerminalExpression and NonterminalExpression with interpret().
  - Trade-offs: easy grammar change and extension — but hard for complex grammars (use a parser generator instead).
- **Iterator** (a.k.a. Cursor) — *Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation.*
  - When: traversal must support multiple simultaneous, polymorphic, or order-varying passes.
  - How: First/Next/IsDone/CurrentItem (or Python's `__iter__`); ExternalIterator controlled by client, InternalIterator driven by the aggregate.
  - Trade-offs: decouples aggregates from traversal — but external iterators expose traversal state; who controls iteration matters.
- **Mediator** — *Define an object that encapsulates how a set of objects interact. Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary their interaction independently.*
  - When: many peer widgets reference each other (spaghetti); interaction must be parameterized.
  - How: colleagues notify the Mediator; the Mediator coordinates colleagues (colleagues know only the mediator).
  - Trade-offs: star topology, one-place interaction logic — but the mediator can become monolithic.
- **Memento** (a.k.a. Token) — *Without violating encapsulation, capture and externalize an object's internal state so that the object can be restored to this state later.*
  - When: snapshots for undo/checkpoints without exposing internals.
  - How: Originator creates/uses a Memento; Caretaker stores it but never inspects it (wide/narrow interfaces, or friend in C++).
  - Trade-offs: preserves encapsulation — but storing full state can be expensive; incremental mementos cost complexity.
- **Observer** (a.k.a. Dependents, Publish-Subscribe) — *Define a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically.*
  - When: changes to one object require changing others and the set of dependents varies at run-time (MVC model→views).
  - How: Subject keeps observers; notify() calls update(); Observers pull state via the subject interface.
  - Trade-offs: abstract coupling, broadcast — but unexpected update cascades and dangling observers on delete.
- **State** (a.k.a. Objects for States) — *Allow an object to alter its behavior when its internal state changes. The object will appear to change its class.*
  - When: behavior depends on state with many conditionals; state-dependent code is duplicated across operations.
  - How: Context delegates state-specific requests to a State object; Context or the states themselves manage transitions.
  - Trade-offs: state-localized behavior, explicit transitions — but state objects multiply; table-driven alternatives exist.
- **Strategy** (a.k.a. Policy) — *Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it.*
  - When: related algorithms differ only in behavior; you want to eliminate conditionals selecting behavior.
  - How: Strategy interface; Context holds a Strategy reference and delegates; strategies chosen at run-time.
  - Trade-offs: eliminates conditional sprawl, alternative implementations — but clients must know strategies and objects multiply.
- **Template Method** — *Define the skeleton of an algorithm in an operation, deferring some steps to subclasses. Template Method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.*
  - When: invariant algorithm steps + variable hooks; factor common behavior into a base class.
  - How: a concrete (often final) method in the base class calls primitive operations that subclasses override.
  - Trade-offs: code reuse + inversion of control ("Hollywood: don't call us, we'll call you") — but every step variant needs a subclass; strategies compose better.
- **Visitor** — *Represent an operation to be performed on the elements of an object structure. Visitor lets you define a new operation without changing the classes of the elements on which it operates.*
  - When: an object structure is stable but operations on it keep arriving (compilers, analysis over ASTs).
  - How: each element calls visitor.visit(this) (double dispatch); one visitX per element class.
  - Trade-offs: easy new operations, related behavior centralized — but hard to add new element classes; visitors can break encapsulation.

## Key Concepts
- **Behavioral class patterns** (Interpreter, Template Method) use inheritance; the other nine use object composition.
- **Encapsulating variation**: Strategy = algorithm; State = state-dependent behavior; Command = request; Memento = state snapshot; Iterator = traversal; Mediator = interaction; Visitor = operation on a structure.
- **Double dispatch**: Visitor works because element.accept(visitor) calls back visitor.visitConcreteElement(this) — resolving both types at run-time.
- **Open-closed asymmetry**: Visitor makes *operations* cheap and *element classes* expensive; the opposite for plain OO composition.

## Mental Models
- "Hollywood principle" (Template Method / frameworks): don't call us, we'll call you.
- "Think of Command as a verb turned into a noun": requests become first-class values — queueable, loggable, undoable.
- "Think of State as Strategy with transitions": State knows its successors; Strategy is stateless and interchangeable.
- "Observer is a newspaper subscription": subjects publish, subscribers react, neither knows the other concretely.

## Anti-patterns
- **Conditionals selecting behavior everywhere** (`if state == X ... elif ...`): → State or Strategy.
- **Sending a request to one hardcoded receiver**: → Chain of Responsibility for implicit receivers.
- **Peer objects referencing each other everywhere**: → Mediator.
- **Undo implemented by copying internals into the invoker**: breaks encapsulation → Memento.
- **Visitor over a volatile structure**: every new element class touches every visitor.

## Code Examples
Observer (Python idiom, from the MVC model→views):
```python
from abc import ABC, abstractmethod

class Observer(ABC):
    @abstractmethod
    def update(self, subject: "Subject") -> None: ...

class Subject:
    def __init__(self) -> None:
        self._observers: list[Observer] = []
    def attach(self, obs: Observer) -> None:
        self._observers.append(obs)
    def detach(self, obs: Observer) -> None:
        self._observers.remove(obs)
    def notify(self) -> None:
        for obs in list(self._observers):
            obs.update(self)

class ClockTimer(Subject):  # the model
    def tick(self) -> None:  # state change
        self._second += 1
        self.notify()      # all views update automatically

class DigitalClock(Observer):  # the view
    def update(self, subject: ClockTimer) -> None:
        self.display(subject.hour, subject.minute, subject.second)
```
- **What it demonstrates**: one-to-many dependency; the model needs no knowledge of its views.

Strategy + Template Method together (Python idiom):
```python
class Composition(ABC):  # Template Method defines the skeleton
    def repair(self) -> None:          # invariant algorithm structure
        self.prepare()
        for line in self.lines():
            self.compose_line(line)     # primitive operation
        self.commit()

    def compose_line(self, line) -> None:
        self.compositor.compose(line, self._natural_size,
                                self._stretch, self._shrink)  # hook

class SimpleComposition(Composition):  # interchangeable algorithm
    def __init__(self, compositor: "Compositor") -> None:
        self.compositor = compositor   # Strategy injected

class TeXComposition(Composition):
    def __init__(self, compositor: "Compositor") -> None:
        self.compositor = compositor
```
- **What it demonstrates**: Template Method fixes the algorithm's shape; Strategy swaps the linebreaking algorithm (Simple/TeX) at run-time.

Command with undo + MacroCommand (Python idiom):
```python
class Command(ABC):
    @abstractmethod
    def execute(self) -> None: ...
    @abstractmethod
    def unexecute(self) -> None: ...

class PasteCommand(Command):  # ConcreteCommand bound to a receiver
    def __init__(self, document: "Document") -> None:
        self._document = document
    def execute(self) -> None:
        self._saved = self._document.clipboard_text()
        self._document.paste()
    def unexecute(self) -> None:
        self._document.delete_selection()

class MacroCommand(Command):  # Composite applied to Command
    def __init__(self) -> None:
        self._cmds: list[Command] = []
    def add(self, cmd: Command) -> None: self._cmds.append(cmd)
    def execute(self) -> None:
        for c in self._cmds: c.execute()
    def unexecute(self) -> None:
        for c in reversed(self._cmds): c.unexecute()  # undo in reverse
```
- **What it demonstrates**: requests as first-class objects; undo; macro via composition.

Visitor with double dispatch (Python idiom):
```python
class NodeVisitor(ABC):
    @abstractmethod
    def visit_assignment(self, n: "AssignmentNode") -> None: ...
    @abstractmethod
    def visit_variable(self, n: "VariableNode") -> None: ...

class ASTNode(ABC):
    @abstractmethod
    def accept(self, v: NodeVisitor) -> None: ...

class AssignmentNode(ASTNode):
    def __init__(self, lhs: "VariableNode", rhs: "ASTNode") -> None:
        self.lhs, self.rhs = lhs, rhs
    def accept(self, v: NodeVisitor) -> None:
        v.visit_assignment(self)   # double dispatch

class TypeCheckingVisitor(NodeVisitor):
    def visit_assignment(self, n: AssignmentNode) -> None: ...
    def visit_variable(self, n: VariableNode) -> None: ...

class CodeGeneratingVisitor(NodeVisitor):
    def visit_assignment(self, n: AssignmentNode) -> None: ...
    def visit_variable(self, n: VariableNode) -> None: ...
```
- **What it demonstrates**: new operations (type-check, codegen) added without touching the node classes.

State (Python idiom):
```python
class TCPState(ABC):
    @abstractmethod
    def active_open(self, conn: "TCPConnection") -> None: ...
    @abstractmethod
    def close(self, conn: "TCPConnection") -> None: ...

class TCPListen(TCPState):
    def active_open(self, conn) -> None:
        conn.change_state(TCPEstablished())  # transition
    def close(self, conn) -> None: ...

class TCPConnection:  # context delegates everything
    def __init__(self) -> None:
        self._state: TCPState = TCPListen()
    def change_state(self, s: TCPState) -> None: self._state = s
    def close(self) -> None: self._state.close(self)
```
- **What it demonstrates**: behavior shifts with internal state — the object "appears to change its class".

## Reference Tables

| Pattern | Aspect that can vary | Key trade-off |
|---|---|---|
| Chain of Responsibility | object that can fulfill a request | may end unhandled |
| Command | when and how a request is fulfilled | class per command |
| Interpreter | grammar and interpretation of a language | impractical for complex grammars |
| Iterator | how an aggregate's elements are accessed, traversed | external state exposure |
| Mediator | how and which objects interact | mediator can bloat |
| Memento | what private info is stored outside, and when | snapshot cost |
| Observer | number of dependents; how they stay up to date | update cascades |
| State | states of an object | state class proliferation |
| Strategy | an algorithm | client must know strategies |
| Template Method | steps of an algorithm | subclass per variant |
| Visitor | operations on object(s) without changing classes | hard to add element classes |

## Worked Example
The GoF compiler: an AST (Composite) accepts many Visitors (type checking, code generation, optimization) via double dispatch; each analysis is a new Visitor class while the AST stays untouched. The reverse trade-off: adding a new node type requires updating every visitor — choose Visitor when the *structure is stable* and *operations churn*.

## Key Takeaways
1. Behavioral patterns encapsulate *what varies*: algorithm (Strategy), state (State), request (Command), interaction (Mediator), traversal (Iterator), operation (Visitor).
2. Command + MacroCommand gives undo/redo and scripting almost for free.
3. Observer abstracts coupling between model and views — the root of MVC.
4. Visitor is the correct answer only when the object structure is stable and operations multiply.
5. Template Method implements frameworks via inversion of control.

## Connects To
- **Ch 2**: Command, Iterator, Visitor in the Lexi case study.
- **Ch 4**: Iterator traverses Composites; Visitor walks them.
- **Ch 6**: patterns as documentation vocabulary.

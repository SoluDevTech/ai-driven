# Chapter 3: Creational Patterns

## Core Idea
Creational patterns abstract the instantiation process: they encapsulate *which* concrete classes the system uses and *how* instances are created and assembled — letting you configure a system with "product" objects that vary widely in structure and functionality.

## Frameworks Introduced
- **Abstract Factory** — *Provide an interface for creating families of related or dependent objects without specifying their concrete classes.*
  - When: a system must be configured with one of multiple families of products; families must be used together.
  - How: AbstractFactory interface declares a creation operation per abstract product; one ConcreteFactory per family; clients use only abstract interfaces.
  - Trade-offs: isolates concrete classes, eases family exchange, enforces consistency — but supporting a *new kind of product* requires changing the factory interface and all subclasses.
- **Builder** — *Separate the construction of a complex object from its representation so the same construction process can create different representations.*
  - When: the algorithm for creating a complex object is independent of its parts and assembly.
  - How: Director drives Builder interface steps; ConcreteBuilder assembles and returns the product. Unlike factories, builders return the product *at the end*.
  - Trade-offs: precise control over construction; internal representation can change; but requires a distinct builder per representation.
- **Factory Method** — *Define an interface for creating an object, but let subclasses decide which class to instantiate.*
  - When: a class can't anticipate the objects it must create; framework users must specialize internals.
  - How: Creator declares the factory method; ConcreteCreator overrides it. "Hooks" into parallel class hierarchies.
  - Trade-offs: no dependence on concrete classes, parallel hierarchies — but clients may need to subclass the Creator just to instantiate.
- **Prototype** — *Specify the kinds of objects to create using a prototypical instance, and create new objects by copying this prototype.*
  - When: run-time instantiation of classes unknown statically; avoiding factory-class explosion; varying only a few product combos.
  - How: Clone() operation on the prototype hierarchy; deep vs shallow copy matters for composite objects.
  - Trade-offs: hides concrete classes, adds/removes products at run-time — but every class needs Clone, and circular references need care.
- **Singleton** — *Ensure a class only has one instance, and provide a global point of access to it.*
  - When: exactly one instance must exist (factories, window managers) and it must be accessible.
  - How: static Instance() with lazy creation; hide the constructor; use a registry for open-ended singletons.
  - Trade-offs: controlled access, per-subclass instances — but the instance is effectively a global, complicating testing and subclassing needs explicit support.

## Key Concepts
- **Class vs object creational patterns**: class patterns use inheritance to vary what's instantiated; object patterns delegate instantiation to another object.
- **Lazy vs eager creation**: Factory Method creates on demand via inheritance; Prototype clones on demand via delegation; Abstract Factory/Builder compose.
- **Factory knowledge encapsulation**: all creational patterns hide *which* concrete classes are used and *how* instances are put together.
- **Maze example**: the recurring worked example — Room/Door/Wall components; each pattern rebuilds the same maze differently.

## Mental Models
- "Configure, don't hard-code": creation should be a parameter of the system, static (compile-time) or dynamic (run-time).
- Competitors *and* complements: Prototype vs Abstract Factory can both work; Builder can *use* Factory Method; Prototype can use Singleton. Pick by what must vary: the family (AF), the construction process (Builder), the subclass (FM), the instance (Prototype), the count (Singleton).
- Factories-as-singletons: an app typically needs one ConcreteFactory per family — implement it as a Singleton.

## Anti-patterns
- **Hard-coding `new` everywhere**: couples clients to concrete classes, making family swaps and testing painful.
- **Using Singleton as a dumping ground for globals**: breaks encapsulation, hides dependencies.
- **Prototype with complex object graphs without deep-copy discipline**: shared references cause subtle bugs.

## Code Examples
Maze creation via Abstract Factory (Python, idiomatic):
```python
from abc import ABC, abstractmethod

class MazeFactory(ABC):
    @abstractmethod
    def make_maze(self) -> "Maze": ...
    @abstractmethod
    def make_wall(self) -> "Wall": ...
    @abstractmethod
    def make_room(self, n: int) -> "Room": ...
    @abstractmethod
    def make_door(self, r1: "Room", r2: "Room") -> "Door": ...

class BombedMazeFactory(MazeFactory):
    def make_maze(self) -> Maze: return Maze()
    def make_wall(self) -> Wall: return BombedWall()
    def make_room(self, n: int) -> Room: return BombedRoom(n)
    def make_door(self, r1, r2) -> Door: return Door(r1, r2)

def create_maze(factory: MazeFactory) -> Maze:
    maze = factory.make_maze()
    r1, r2 = factory.make_room(1), factory.make_room(2)
    maze.add_room(r1); maze.add_room(r2)
    r1.set_side(Direction.NORTH, factory.make_wall())
    r1.set_side(Direction.EAST, factory.make_door(r1, r2))
    return maze  # swap factory -> swap the whole game world
```
- **What it demonstrates**: the family of maze components is created through one interface; a `BombedMazeFactory` swaps the entire game world.

Factory Method (Python idiom):
```python
class MazeGame(ABC):
    def create_maze(self) -> Maze:
        maze = self.make_maze()
        room1 = self.make_room(1)
        maze.add_room(room1)
        return maze

    # factory methods — deferred to subclasses:
    @abstractmethod
    def make_maze(self) -> Maze: ...
    @abstractmethod
    def make_room(self, n: int) -> Room: ...

class EnchantedMazeGame(MazeGame):
    def make_maze(self) -> Maze: return EnchantedMaze()
    def make_room(self, n: int) -> Room: return EnchantedRoom(n, cast_spell())
```
- **What it demonstrates**: subclasses override the factory methods — instantiation deferred to subclasses.

Prototype (Python idiom — `copy.deepcopy` plays the role of Clone):
```python
import copy

class Wall(ABC):
    @abstractmethod
    def clone(self) -> "Wall": ...

class BombedWall(Wall):
    def __init__(self, blown: bool = False) -> None:
        self.blown = blown
    def clone(self) -> "BombedWall":
        return copy.deepcopy(self)

class MazePrototypeFactory(MazeFactory):
    def __init__(self, maze: Maze, wall: Wall, room: Room, door: Door) -> None:
        self._prototype_maze, self._prototype_wall = maze, wall
        self._prototype_room, self._prototype_door = room, door
    def make_maze(self) -> Maze: return copy.deepcopy(self._prototype_maze)
    def make_wall(self) -> Wall: return self._prototype_wall.clone()
    def make_room(self, n: int) -> Room:
        room = copy.deepcopy(self._prototype_room); room.room_number = n
        return room
```
- **What it demonstrates**: creation by cloning; run-time-configurable maze game with no factory-class proliferation.

Builder (Python idiom):
```python
class MazeBuilder(ABC):
    def build_maze(self) -> None: pass
    def build_room(self, n: int) -> None: pass
    def build_door(self, room_from: int, room_to: int) -> None: pass
    def get_maze(self) -> Maze | None: return None

class CountingMazeBuilder(MazeBuilder):
    def __init__(self) -> None:
        self._doors = self._rooms = 0
    def build_room(self, n: int) -> None:
        self._rooms += 1
    def build_door(self, a: int, b: int) -> None:
        self._doors += 1
    def get_maze(self) -> Maze | None: return None  # counts only

class MazeGame:
    def create_maze(self, builder: MazeBuilder) -> Maze | None:
        builder.build_maze()
        builder.build_room(1)
        builder.build_room(2)
        builder.build_door(1, 2)
        return builder.get_maze()  # same Director, different representations
```
- **What it demonstrates**: the Director runs the same construction steps; the builder decides the representation (`StandardMazeBuilder` assembles a Maze, `CountingMazeBuilder` just counts).

## Reference Tables

| Pattern | Aspect that can vary | Key trade-off |
|---|---|---|
| Abstract Factory | families of product objects | new product *kinds* are hard to add |
| Builder | how a composite object gets created | one builder per representation |
| Factory Method | subclass of object that is instantiated | may require subclassing the Creator |
| Prototype | class of object that is instantiated | every class needs Clone() |
| Singleton | the sole instance of a class | effectively a global; testability |

## Worked Example
The GoF maze: `CreateMaze()` builds rooms/walls/doors. Written naively it's locked to Maze/Wall/Room. With a MazeFactory parameter (Abstract Factory) it accepts Bombed or Enchanted variants; with factory methods it defers to EnchantedMazeGame subclasses; with prototypes it clones prototypes registered at run-time; with a Builder it can build the *same* maze differently (Standard vs Counting builder). Same product, five different creation stories.

## Key Takeaways
1. Creational patterns make a system independent of *how* objects are created, composed, represented.
2. Choose by what must vary: family → AF; construction algorithm → Builder; subclass → FM; instance class → Prototype; count → Singleton.
3. Abstract Factory is often implemented with Factory Methods or Prototypes inside.
4. Prototype eliminates factory-class proliferation when there are many families.
5. Factories as singletons is the standard implementation practice.

## Connects To
- **Ch 2**: Abstract Factory for look-and-feel kits.
- **Ch 4**: Builder builds Composite structures; Facade often fronts a subsystem created by factories.
- **Ch 5**: Command often needs factories for undoable/parameterized requests.

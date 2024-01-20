# Can Debugging Be Liberated from the von Neumann Style?

## The early history of debugging

The first programming languages were machine codes and assembly languages. An assembly program is a sequence of instructions:

```assembly
mov ax, bx
add ax, dx
shr ax, 1
mov si, ax
add si, si
cmp cx, arr[si]
```

Each instruction changes the program's state - registers and memory.

When debugging such a program, we move through the program instruction by instruction, and at each step, we can inspect the state of registers and memory. Although the language is low-level, the debugging model is simple and maps well to the language model.

## High-level languages

With the advent of high-level languages, something new emerged. We gained the concept of __values__.

Consider a program that calculates the length of a vector:

```javascript
function vec_len(vec) {
  return Math.sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
}
```

What's new compared to assembly:

- We have the notion of __values__ separate from registers or memory locations.
- Unlike registers and memory locations, which are mutable, values are immutable.
- Operations on values emerged. `+` and `*` are built-in operations. Custom operations can also be defined. `Math.sqrt` is a custom operation defined in the standard library.
- Operations and values constitute expressions. An expression takes a value, applies an operation, and creates a new value.
- Expressions are closed under composition. We can compose complex expressions from simple ones. Intermediate values seem to hang in the air. We don't care about the specific memory cells they occupy.

An assembly program is a __sequence__ of instructions. An expression is a __tree__. In each node of this tree, we have an operation, either built-in or custom, applied to immutable values, producing other immutable values. The tree is a more complex data structure than a sequence.

At a low level, expressions are evaluated using machine instructions. But it's no longer clear to us how this happens.

## Expressions require different debuggers

If in assembly debuggers, we traversed a sequence, with expressions, we need to traverse a tree. When a program in a conventional programming language is executed, the expression tree is traversed in a depth-first order.

**Here arises a key idea - what if we allow the programmer to traverse the tree during debugging not in the order it happened during program execution but in an arbitrary order, as convenient?**

<span id='expression_debugger'>Here's how it's implemented in [Leporello.js](https://leporello.tech).</span> Using a shortcut, we highlight an expression and see its value. You can highlight any expression, and you can do it in any order:

<video src='./expression.mov' controls></video>

## The von Neumann style

In his [Turing Award lecture](https://dl.acm.org/doi/pdf/10.1145/359576.359579), John Backus introduces the concept of the von Neumann style, referring to the [von Neumann architecture](https://en.wikipedia.org/wiki/Von_Neumann_architecture). A von Neumann machine consists of a CPU, memory, and a bus that transfers data between the CPU and memory one machine word at a time. Backus calls this bus the von Neumann bottleneck. According to Backus, modern programming languages are high-level von Neumann computers.

Modern computers significantly differ in architecture from the primitive von Neumann machine. However, in terms of debugging, we still face the von Neumann bottleneck. During debugging, we execute the program one instruction at a time. We lack a higher-level model and representation of program execution.

According to Backus, von Neumann style programs are divided into two worlds - expressions and statements. Expressions have useful algebraic properties that statements lack. How does this relate to debugging? When dealing with an expression where each operation transforms immutable arguments into an immutable result, we have [rich debugging tools](#expression_debugger). With statements, we lack such tools. We can only execute the program statement by statement, without the ability to go back in time.

In widely accepted programming languages, each expression can have side effects:

<video src='./debugger_side_effect.mp4' controls></video>

<div style='text-align:center; font-style: italic; margin-bottom: 1em'>Hovering over an expression can produce side-effects</div>

In current debuggers, we are stuck in the von Neumann style. This raises the question posed in the title of this article - can debugging be liberated from the von Neumann style?

## From von Neumann debugging to functional debugging

As an alternative to the von Neumann style, Backus proposes functional programming. In functional programming, the entire program is one large expression.

We can formulate principles that allow us to move from von Neumann debugging to functional debugging:

- A program is not a sequence of instructions that are fetched and executed word by word. It is a tree of expressions.

- The programmer should be able to traverse this tree in any order that is convenient for them. For each node in this tree, they should be able to inspect the arguments and the returned value.

## Why spreadsheet software is so popular?

An interesting phenomenon is the popularity of spreadsheets among non-programmers. Spreadsheets are extremely intuitive and easy to learn. The reason lies in the fact that spreadsheets are based on a functional model.

_"The world’s most widely used programming language is a purely functional language! It’s called Excel. No mutable cells, assignment statements, or sequencing; just pure functions and immutable values"_ - Simon Peyton Jones

When using Excel, we are freed from von Neumann-style debugging. We simply input information, and the values of all cells are recalculated. We can click on any cell and inspect its value.

_"Imagine a spreadsheet where every time you change something you must open a terminal, run the compiler and scan through the cell / value pairs in the printout to see the effects of your change. We wouldn't put up with UX that appalling in any other tool but somehow that is still the state of the art for programming tools."_ - [Jamie Brandon](https://www.scattered-thoughts.net/writing/pain-we-forgot/)

## How Leporello.js breaks free from the von Neumann style

[Leporello.js](https://leporello.tech) views the entire program as one giant expression tree:

<video src='./calltree.mov' controls></video>

In the video, you can see how Leporello.js allows exploring the call tree of a program. The programmer can traverse the nodes of this tree in any order, inspecting the values of arguments, the returned value, and the values of all intermediate expressions.

Leporello.js eliminates the von Neumann bottleneck, the need to execute the program instruction by instruction in the debugger. In conventional debuggers, debugging is a process that unfolds over time. However, conventional debuggers do not give us tools to make time tangible. It's like video editing software that doesn't show us the timeline but instead suggests rewinding the video from the beginning every time.

Because conventional debuggers don't provide a timeline, many programmers prefer not to use interactive debuggers at all. Instead, they use print debugging. Lines in the debug printout play the role of a timeline, allowing them to scroll forward and backward through the program's execution.

## Breaking free from von Neumann style debugging with imperative languages

Backus suggested functional programming as an alternative to the von Neumann style. Can we liberate imperative languages from von Neumann-style debugging? The answer is yes! The [recent release of Leporello.js](https://leporello.tech/blog/mutable_data/) enables functional debugging for imperative programs.

## Conclusion

Since the early assembly languages, programming languages have made tremendous progress. At the same time, we haven't seen a corresponding advancement in program debugging. Many programmers do not use interactive debuggers at all, preferring print debugging - a method available even in the days when computers had printers instead of displays. As Brian Kernighan said, "Debugging is twice as hard as writing the code in the first place." To simplify programming, we must think about making debugging easier. In our opinion, there is significant potential in transitioning from von Neumann style debugging to functional expression-style debugging.

# Leporello.js now supports time-travel debugging for mutable data

_4 Jan 2024_

I've prepared a big New Year update for you on Leporello.js!

Initially, Leporello.js was conceived as an IDE for a pure functional subset of JS. This allowed for quickly creating a working prototype and testing out ideas. But it's time to move forward. Now, Leporello.js also supports mutable data while retaining all of its declared functionality and expanding it! We've taken an important step towards supporting the full subset of JavaScript!

To get an idea of how this works now, take a look at this very short video:

<video src="./mutability_1.nosound.mov" controls>
<pre>
  const array = [3,2,1]

  array.push(4)

  array[0] = 5

  array.sort()
</pre>
</video>


By selection an expression whose value is an object, you can see its state at the moment when that value was computed by the JS interpreter.

<a id='unionAll'>When you choose any function call within the call tree, all values will be shown at the moment of that particular call:</a>

<video src="./mutability_2.nosound.mov" controls>
<pre>
  const x = new Set([1,2])
  const y = new Set([3,4,5,6])

  function unionWith(a, b) {
    b.forEach(elem => {
      a.add(elem)
    })
  }

  unionWith(x, y)
</pre>
</video>

When you select a call within the call tree, the arguments are displayed with their values at the moment of the function call, while the returned value is shown at the moment of returning from the function:

<video src="./mutability_3.nosound.mov" controls>
<pre>
  function do_sort(array) {
    array.sort()
    return array
  }

  do_sort([5,4,3,2,1])
</pre>
</video>

In the 'Logs' view values are also displayed at the moment of the console.log function call.

<img src='./mutability_4.png'>

Here, there's no cheating like what happens, for example, in the Chrome console. In the Chrome console, when you output an object, a shallow copy of it is made. But if you start inspecting the object, you see the nested objects at the moment when you do that, not at the moment when the console.log was called.

Leporello's time-travel debugging is honest. All nested objects are displayed with values at the required moment. You can inspect nested objects at any depth. Leporello.js also doesn't make deep copies, as that would negatively impact performance for non-trivial programs with large data volumes. Instead, it uses a scalable and high-performance implementation.

Leporello.js transparently wraps all mutable objects - arrays, objects, Sets, and Maps - within a proxy. The proxy retains the initial value and attaches a redo log to every mutable object. Additionally, a global change counter increments with each mutation. All the mutations made to a proxy are recorded to a redo log structured as an array with entries such as "the value at index 10 was modified to this" or "method sort() was invoked". By utilizing an initial value and a redo log, we can replay the redo log and retrieve a version of the object for any value of the change counter.

For each calltree node, we retain both the initial value (at the moment of a call) and the final value (at the moment of return) of the change counter. This mechanism enables us to pinpoint the accurate value of the change counter while navigating the calltree.

Crucially, Leporello.js refrains from materializing the entire calltree in memory during the program's initial execution. Instead, it evaluates the branches of it lazily, as the user navigates the call tree. It bypasses the necessity to retain all mutations made to minute objects. Most short-lived objects swiftly undergo garbage collection, along with their associated redo logs.

I intend to delve deeper into the intricacies of Leporello.js in upcoming blog posts. Stay tuned by subscribing to [Twitter](https://twitter.com/leporello_js) or RSS for timely updates.

## Limitations

However, current implementation has a big limitation. Leporello.js does not instrument third-party libraries. Consequently, debugging becomes compromised when employing mutable objects from such libraries. As a result, its usage is presently confined to libraries that exclusively provide immutable data. While I hold the belief that the overall design is robust, its implementation should ideally occur within the JS interpreter, not by instrumenting the source code.

Leporello.js carries the burden of utilizing a subpar homemade JS parser. If you encounter issues with code parsing while using Leporello, I urge your understanding. The parser's capabilities are rudimentary. Notably, it lacks support for loops, a deficiency stemming from its original focus on functional programming (FP) where loops aren't typically employed. Nonetheless, you can leverage array methods such as `map`, `forEach`, and similar alternatives. More information on supported JS subset you can find [here](https://github.com/leporello-js/leporello-js?tab=readme-ov-file#supported-javascript-subset)

## Next steps

I plan to add support for loops later. Every loop will be a separate node in a calltree, with every iteration of the loop being a separate child node. Therefor, in the call tree view, loops will be represented similar to how array methods like `map` and `forEach` look currently (see [the previous example](#unionAll)).

## Interested in Leporello.js?

If you are interested or have any questions, please <a href="mailto:dmitry.vasil@gmail.com?subject=Leporello.js">email me</a>. I'm available and eager to respond to any emails you may have.

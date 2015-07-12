# sμdoku

A no-nonsense Sudoku web app. Works great on PC and mobile. Built to be clean and responsive, but with a full set of features.
No missing features, annoying ads, accounts, or weird themes. Just sudoku.

Unlike some apps which seem to have databases of pre-generated puzzles, sμdoku generates new games on the fly. All
puzzles are guaranteed to be solvable, but they can be quite hard if you are new to Sudoku (~26 squares are filled in
when the game starts).

Because it doesn't need to get new puzzles from a database/list, sμdoku fully supports offline use (for example, on a smartphone).

Supports "notes", meaning that you can select multiple numbers in a single square and they will all be saved and displayed.
This is a feature that many Sudoku implementations lack, but it can be quite useful for making reminders for yourself if
you are struggling through a tough puzzle.

## Tips and hidden features

I tried to keep the UI as clean as possible, so it's "just sudoku". But there are some power-user features hidden under
the hood. Most of them are triggered by right-clicking (on desktop) or long-pressing (on mobile).

* **Undo all**: Right-click or long-press the "Undo" button to undo everything. Useful for resetting the game. Does not restart the timer, though!
* **Redo all**: Right-click or long-press the "Redo" button to redo everything you undid. Equivalent to spamming Redo a bunch of times, but more efficient.
* **Clear all**: Right-click or long-press the "New Game" button to completely clear the board. Useful for entering your own puzzles to solve with the auto-solver.
* **Auto-solve**: Right-click or long-press the "Hint" button to completely solve the puzzle. This resets the game timer, because it's basically cheating.
* **Select/deselect all**: Right-click or long-press any of the number buttons (below the board) to either add or remove *all* numbers from the selected square.

## Why the μ?

The Greek character "μ", pronounced "mu", looks cool. If you take off the "s", it becomes μdoku, which can be read "mu-doku".

Also, μ is used in SI prefixes to mean "micro", so it fits with the lightweight/minimal theme. In fact, techincally the characters used in this README are the SI prefix U+00B5, not the Greek character U+03BC.

Finally, μ evokes the Japanese "mu", which is an important concept in Zen Buddhism. Literally, it means "without",
but for Zen Buddhism it can be considered more of a fundamental absence. Neither a positive nor a negative, it is the
absence of either, or equivalently, the undifferentiability of both. Confused? Meditate on this classic Zen Buddhist koan:

> A Zen monk asked his master, "Is it you playing Sudoku, or is it the computer?"
>
> The Zen master replied, "Mu."

## How puzzles are generated and solved

The Sudoku puzzle solver uses simple constraint propagation. Peter Norvig wrote a [nice page](http://norvig.com/sudoku.html)
about solving Sudoku puzzles using constraint propagation. My algorithm is a simplified version of the final one he presents.

Puzzle generation is a lot harder, computationally. sμdoku starts by shuffling the board, and then it generates a completely solved
puzzle by adding valid numbers one at a time, propagating the new constraints each time a number is added. My algorithm does not
include backtracking because it is very fast. If it walks itself into a corner, it will just try again from scratch. Once
the complete puzzle is generated, the algorithm will begin to randomly remove numbers until it reaches the desired difficulty.
Each time a number is removed, the puzzle is solved, so that if we accidentally introduce ambiguity, we can try again by
removing a different set of numbers. So in the course of generating a puzzle, the solver may run many hundreds of times.

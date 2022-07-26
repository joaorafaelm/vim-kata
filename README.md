# vim-kata

A vim plugin to help you improve your Vim muscle memory.

## Demo

![Screencast](https://github.com/dankilman/vim-kata/raw/master/doc/demo.gif)

## Usage

Install this plugin with any plugin manager.

Start the plugin with `<C-L>`.
After `vim-kata` is loaded, the first kata should appear in a new tab (first being the first in the newly shuffled order).

`vim-kata` uses the Vim diff display mode.

The left window is the input text. This is where you edit the text.

The right window is the output text. This is what your editing should look like. This buffer is `'unmodifiable'`.

Once you are done with a kata:

* `<C-L>` to start kata in a new tab.
* `<C-J>` to load the previous kata.
* `<C-K>` to reload the next kata.
* `<C-G>` to load a specific kata by directory name (thanks [@oflisback](https://github.com/oflisback)).
* `ZQ` to quit (mapped to `qa!`).

## Tips

Each kata in the `katas` dir includes an additional `tips` file.

This file gives an informal description of the key sequences I tend to use when doing the kata.

The tips are usually trying to strike a balance between fewer keystrokes, while remaining pragmatic and
easier to reuse across different similar situations.
They are not optimizing for minimal keystrokes like VimGolf does.

Type `g?` to display tips for the current kata.

## Configuration

The `config.vim` file contains the configuration options for `vim-kata`.

## Adding Katas

All katas are stored in the `katas` directory.

Each kata is a directory comprised of 4 files: `in`, `out`, `ext` and `tips`.
The `in` and `out` are self explanatory.

The `ext` file is optional. It contains the file extension that should be used.
This is relevent when you want a certain kata to have syntax highlighting.
If `ext` doesn't exist, `txt` extension is used.

If `tips` exists, it will displayed when typing `g?`.

To add a kata, simply create a new directory with this structure.

### Custom cursor start location

To have a kata start with the cursor positioned at a custom location,
add a literal `<C-K>` (`^K`) to the `in` document (not the `out`!). The kata will load with the cursor
at that position, and the literal `<C-K>` will be removed.

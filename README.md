# SimpleLang

A simple programming language interpreter written in C3.

## Overview

SimpleLang is a lightweight language implementation featuring a handcrafted lexer, parser, and interpreter. It provides an interactive Read-Eval-Print Loop (REPL) for executing code on the fly.

## Features

- **Interactive REPL**: Execute code line-by-line.
- **Tree-Walk Interpreter**: Implements a visitor-based interpreter.
- **Written in C3**: Showcases C3 language features using modern constructs.

## Language Details

SimpleLang supports the following:

- **Variables**: Global variable declarations using `let`.
- **Types**: Integers and Strings.
- **Arithmetic**: Basic operations (`+`, `-`, `*`, `/`) with operator precedence.
- **Input/Output**: Printing to console.

### Example

```
let x = 10;
let y = 20;
print (x + y) * 2;
```

## Getting Started

### Prerequisites

- [C3 Compiler](https://c3-lang.org/) (latest version recommended)

### Build and Run

To build and run the project, use the C3 compiler:

```bash
# Run directly
c3c run

# Build executable
c3c build
./build/simplelang.exe  # or ./build/simplelang on non-Windows
```

## Usage

Simply run the executable to enter the REPL:

```
simplelang> 1 + 2 * 3
7
```

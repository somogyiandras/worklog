# Worklog

Worklog is a Haskell command-line project for turning structured Markdown workfiles into an overview of ongoing cases, outstanding work, and related documents.

The central idea is to keep each case in a human-editable workfile while using a separate program to collect, analyze, and eventually report on those files. Workfiles remain the source of truth; Worklog is not intended to replace the editor in which they are maintained.

> **Development status:** Worklog is under active development and is not yet a complete case-management or reporting application. The current executable is a prototype, not the planned multi-command CLI.

## Motivation

A workfile contains information about one case: its title, status, deadline, summary, and associated activities. Maintaining cases as Markdown files keeps the records readable, versionable, and compatible with existing text-editing tools.

Worklog aims to make that collection of files useful as a whole by discovering workfiles recursively, extracting structured data, and generating consolidated views without requiring manual duplication.

## What works today

The repository currently includes:

- Domain types for cases, case-specific to-do items, tasks, and attachments.
- A common `Summary` abstraction and some case-analysis helpers.
- Recursive discovery of files matching a configurable extension.
- A Pandoc-based Markdown reader and preliminary title extraction from document metadata.
- A prototype executable using `optparse-applicative` for `--dir` and `--ext`.
- Tests built with Tasty, including filesystem tests using temporary directories.

The current executable discovers matching workfiles and prints their extracted titles. It also emits temporary diagnostic case output. File traversal ordering, validation, and error handling are not yet finalized.

## Planned workflow

The intended command-line interface is:

```text
worklog <command> <options>

commands: list, save, load, report, todos, tasks
```

The first milestone is to read workfiles into validated `Case` values, store a versioned application state, and produce a Markdown report. Standard input/output streams will allow pipelines such as:

```sh
worklog save | worklog report | pandoc -dreport
```

**These commands and the pipeline above are design goals, not currently supported functionality.**

Later development may introduce a terminal interface, configurable templates, richer reports, attachment navigation, and generated letters.

## Getting started (development)

The project uses Cabal and GHC. With a compatible Haskell toolchain:

```sh
cabal build all
cabal test all
cabal run worklog -- --help
```

To run the current prototype against a directory of workfiles:

```sh
cabal run worklog -- --dir PATH --ext wmd
```

Both `wmd` and `.wmd` are accepted by the CLI and normalized internally.

See [TODO.md](TODO.md) for the staged implementation plan and the documentation roadmap.

## Repository layout

| Location | Purpose |
| --- | --- |
| `src/Worklog/` | Domain types, file discovery, and the initial Markdown reader |
| `src-internal/` | Shared internal abstractions |
| `app/` | Current command-line executable |
| `test/`, `test-internal/` | Automated tests |
| `TODO.md` | Roadmap and work-in-progress tasks |

## Data considerations

Workfiles may contain confidential case information. Use fictional or anonymized examples in the repository and its tests; do not commit actual working documents or sensitive case data.

## License

This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE).

# Todo list for the project

# Main features planned for the application

## Version 1.0

- [ ] Input formats: Markdown
- [ ] Output formats: Markdown, HTML
- [ ] CLI, Command Line Interface
- [ ] List workfiles in order (deadline, rank)
- [ ] Filter workfiles (status, deadline)
- [ ] Create report

## Further development goals

- [ ] TUI, Terminal User Interface
- [ ] Open workfiles in Vim/Neovim
- [ ] Create, list, modify, delete session files

  (Session files are created and used in Vim)

- [ ] Other workfile input formats (docx)
- [ ] Other output formats
- [ ] Session or project support:

  Create and handle projects/sessions which connect the workfile to other files.
  For example for one workfile the project contains the related files (images, letters,
  pdf, code, etc.)

  - [ ] Show "project worktree"
  - [ ] Preview files
  - [ ] Open project in defined application (Vim session)

- [ ] Pandoc integration
- [ ] Configuration options
- [ ] Custom workfiles
- [ ] Option to create additional documents based on workfile content

  For example: create letter based on selected parts of the workfile and using user created templates.
  The address, and parts of the letter is from the workfile.

# Step by step list to reach Version 1.0 goals

## Current milestone: first usable command-line pipeline

This is the current minimum goal. It is intentionally smaller than Version 1.0.
The program should support the following interface:

```text
worklog <command> <options>

commands:
  list
  save
  load
  report
  todos
  tasks
```

The intended pipeline is:

```text
worklog save | worklog report | pandoc -dreport
```

For every command, normal command output must go to standard output. Diagnostics and
errors must go to standard error so that pipelines are not corrupted.

### 0. Check and stabilize the current repository state

- [x] Review current `main` state at commit `10202f0110218cadd541be1757be81efe0bf1f0b` (2026-09-19).
- [x] Current code builds and the existing tests pass locally.
- [x] Basic domain modules already exist: `Case`, `Todo`, `Task`, `Attachment`, `CaseAnalysis`.
- [x] `Summary` is hidden behind the `HasSummary` API.
- [x] Make the small `Case` API corrections before new modules depend on it:
  - [x] Rename `deferrCase` to `deferCase`.
  - [x] Rename `getDefferedDay` to `getDeferredDay`.
  - [x] Add a read-only way to obtain the case status if the new infrastructure needs it
        (for example `getCaseStatus :: Case -> Status`).
  - [x] Erase the status changing functions. This API version cannot change it, the Parser
        will create Case with the status burned in the workfile.
  - [x] Update/add tests for these changes.

### 1. Implement recursive workfile discovery

Create a small module responsible only for locating workfiles. Do not mix Markdown
parsing into this module.

- [x] Create `Worklog.Scan` (or similarly focused module).
- [x] Implement recursive directory traversal.
- [x] Select files by extension.
- [x] Defaults:
  - [x] directory: `.`
  - [x] extension: `wmd`
- [ ] Decide one canonical CLI representation for the extension (`wmd`); the scanner may
      accept a leading dot as a convenience, but internally normalize it.
- [ ] Return paths in deterministic order.
- [x] Keep the source path outside `Case`; path is application/index state, not a domain
      attribute of a case.
- [ ] Add focused tests for extension matching and recursive discovery.
- [ ] Add Cabal dependencies needed by this step (`directory`, `filepath`) only when used.

### 2. Define the minimal workfile parser

The exact extraction rules must be based on a real/anonymized workfile supplied outside
the repository. Do not commit real workfiles containing case data.

- [ ] Create `Worklog.Parser`.
- [ ] Define a parser API which reports the source file in parse errors.
- [ ] Use Pandoc to read the Markdown workfile; `pandoc` is already a library dependency.
- [ ] For the first parser milestone extract only the data required by the current CLI:
  - [ ] case title
  - [ ] case status: `OnDesk`, `Deferred`, `Archived`
  - [ ] case deadline
  - [ ] `Todo` items
  - [ ] `Task` items
- [ ] Ignore case summary, flags and attachments in the first parser milestone unless they
      are required to construct a valid `Case`.
- [ ] Extract Todo items from their structured Pandoc representation.
- [ ] Define the Task extraction rule after reviewing the supplied workfile; currently Task
      is still primarily represented as text.
- [ ] Convert parsed values into domain values using the public domain API instead of
      exposing the `Case` constructor.
- [ ] Decide and test parser behaviour for invalid or missing mandatory metadata.
- [ ] Add anonymized parser fixtures and parser tests only after the format is fixed.

### 3. Introduce `ApplicationState`

`ApplicationState` is the boundary between scanning/parsing and commands which consume a
previously saved state.

- [ ] Create `Worklog.ApplicationState`.
- [ ] Store the parsed `Case` values together with their relative source paths in the
      application state (for example with an `IndexedCase` type or a map). Do not add the
      path to `Case` itself.
- [ ] Provide a small public API for constructing and reading the state.
- [ ] Use JSON as the first persistent `ApplicationState` format.
- [ ] Add a top-level format version to the JSON representation so the state file can evolve
      later without silently changing meaning.
- [ ] Keep JSON encoding/decoding separate from CLI argument parsing.
- [ ] Add round-trip tests: encode -> decode must preserve the minimum state required by
      `load`, `report`, `todos` and `tasks`.
- [ ] Add Cabal dependencies needed by this step (most likely `aeson` and `bytestring`; add
      `text` only if the implementation actually uses it).

### 4. Add pure filtering and query functions

Keep selection/query logic out of `Main` and out of the renderers.

- [ ] Extend `Worklog.CaseAnalysis` or add a small state-query module.
- [ ] Implement status-category filtering for:
  - [ ] `OnDesk`
  - [ ] `Deferred`
  - [ ] `Archived`
- [ ] Treat the CLI status option as a status category/selector, not directly as the domain
      `Status` value, because `Deferred` also contains a date.
- [ ] Default status selector for `list` and `save`: `OnDesk`.
- [ ] Implement a query which returns all Todos together with their parent case title.
- [ ] Implement a query which returns all Tasks together with their parent case title.
- [ ] Add tests for status filtering and Todo/Task flattening.

### 5. Implement pure text and Markdown renderers

The renderers should be pure functions. File handles and standard input/output belong to
the command execution layer.

- [ ] Create `Worklog.Render` or equivalent focused renderer modules.
- [ ] Implement the one-line case renderer used by `list` and `load`:
  - [ ] one case per line
  - [ ] title
  - [ ] deadline in ISO form (`YYYY-MM-DD`)
  - [ ] represent `NoDeadline` consistently (for example `-`)
- [ ] Implement Todo output in the required form:

  ```text
  <todo summary> - <case title>
  ```

- [ ] Implement Task output in the required form:

  ```text
  <task summary> - <case title>
  ```

- [ ] Implement the first Markdown report renderer.
- [ ] Keep the first report deliberately small. For each case include at least:
  - [ ] title
  - [ ] status
  - [ ] deadline
  - [ ] Todos
  - [ ] Tasks
- [ ] Do not implement direct HTML rendering for this milestone; Markdown output can be
      piped into Pandoc.
- [ ] Add golden or exact-string tests for the renderers.

### 6. Implement the CLI parser

Use a real command parser instead of hand-written `getArgs` matching. `optparse-applicative`
is the preferred dependency for this interface.

- [ ] Create `Worklog.CLI`.
- [ ] Model commands and options as Haskell data types before executing IO.
- [ ] Add `optparse-applicative` to the executable dependencies.
- [ ] Implement `list` options:
  - [ ] `-d DIR`, `--directory=DIR`, default `.`
  - [ ] `--extension=EXT`, default `wmd`
  - [ ] `-s STATUS`, `--status=STATUS`, default `OnDesk`
- [ ] Implement `save` options:
  - [ ] same directory, extension and status options as `list`
  - [ ] `-o FILE`, `--output=FILE`
  - [ ] without `--output`, write JSON `ApplicationState` to standard output
- [ ] Implement `load` options:
  - [ ] `-i FILE`, `--input=FILE`
  - [ ] without `--input`, read JSON `ApplicationState` from standard input
- [ ] Implement `report` options:
  - [ ] `-i FILE`, `--input=FILE`, default standard input
  - [ ] `-o REPORT`, `--output=REPORT`, default standard output
- [ ] Implement `todos` options:
  - [ ] `-i FILE`, `--input=FILE`, default standard input
  - [ ] output always goes to standard output
- [ ] Implement `tasks` options:
  - [ ] `-i FILE`, `--input=FILE`, default standard input
  - [ ] output always goes to standard output
- [ ] Add parser tests for commands, long options, short options and defaults.

### 7. Implement command execution and keep `Main` thin

- [ ] Create a command execution layer (for example `Worklog.Command`).
- [ ] `Main.main` should only parse CLI arguments, dispatch the command and handle the final
      exit status.
- [ ] Implement `list`:
  - [ ] scan directory recursively
  - [ ] parse matching workfiles
  - [ ] filter by status
  - [ ] render one line per case
- [ ] Implement `save`:
  - [ ] use the same scan/parse/filter path as `list`
  - [ ] build `ApplicationState`
  - [ ] encode it as JSON
  - [ ] write to selected file or stdout
- [ ] Implement `load`:
  - [ ] read selected file or stdin
  - [ ] decode `ApplicationState`
  - [ ] list all cases in the state using the same line renderer as `list`
- [ ] Implement `report`:
  - [ ] read/decode `ApplicationState`
  - [ ] render Markdown
  - [ ] write to selected file or stdout
- [ ] Implement `todos`:
  - [ ] read/decode `ApplicationState`
  - [ ] list Todo summary and parent case title
- [ ] Implement `tasks`:
  - [ ] read/decode `ApplicationState`
  - [ ] list Task summary and parent case title
- [ ] Never write informational/debug text to stdout when stdout contains JSON, Markdown or
      list output.
- [ ] Send parse/decode/IO errors to stderr and return a non-zero exit code.

### 8. End-to-end acceptance tests for the milestone

Use only anonymized fixture workfiles.

- [ ] `worklog list` works with all defaults.
- [ ] `worklog list -d DIR --extension=wmd --status=Deferred` filters correctly.
- [ ] `worklog save > state.json` writes valid JSON only.
- [ ] `worklog load < state.json` lists the cases from the saved state.
- [ ] `worklog save | worklog load` works as a pipe.
- [ ] `worklog save | worklog todos` works as a pipe.
- [ ] `worklog save | worklog tasks` works as a pipe.
- [ ] `worklog save | worklog report` produces valid Markdown only.
- [ ] `worklog save | worklog report | pandoc -dreport` works without intermediate files.
- [ ] File-based `--input` and `--output` alternatives work for `save`, `load` and `report`.
- [ ] A malformed workfile reports the affected path and exits with failure.
- [ ] A malformed JSON state reports an error on stderr and does not emit partial normal
      output on stdout.
- [ ] Linux build/tests still pass.
- [ ] Windows build still succeeds with the existing GitHub Actions workflow.

### 9. Explicitly postpone non-essential features until the CLI milestone works

The following are useful Version 1.0/future features, but they must not block the first
usable command-line pipeline:

- [ ] ranking/priority-based ordering
- [ ] direct HTML output from `worklog`
- [ ] richer report layout/CSS integration
- [ ] attachment parsing/rendering
- [ ] outgoing-document workflow
- [ ] full summary parsing
- [ ] advanced flags/attention analysis
- [ ] TUI
- [ ] Vim/Neovim opening from the application
- [ ] configuration files and custom workfile schemas

## Immediate next implementation step

Implement **Step 0 domain API corrections**, then **Step 1 recursive workfile discovery**.
These steps do not depend on the still-to-be-supplied real/anonymized workfile structure.
After that, provide an anonymized workfile and implement the parser against the actual
Markdown/Pandoc structure instead of guessing its syntax.

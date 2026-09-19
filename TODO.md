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

- [ ] Check current state (2026. szeptember 19.)
- [ ] Create modules (with minimal testable state)
    - [ ] Parse
    - [ ] CLI
    - [ ] RenderReport
    -
      

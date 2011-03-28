## 0.4.0 (March 28, 2011)

Features:

  - Added a 'section' operation to allow for subsection grouping in commands, for greater clarity.

Fixes:

  - 'parsimonious' operation failed to handle global options.
  - Renamed 'header' to 'heading'.
  - Fixed 'default' operation for SuperCommands.
  - Made sure the usage width in manpages is reasonable.
  - 'help' subcommand now exposed via the 'command' operation, so that the '--help' option can be attached to options.
  - '&.' bug in the manpage output.
  - Added a 'gem cleanup' to the rake integration.

## 0.3.5 (March 26, 2011)

Features:

  - Added additional rake tasks to make creating a release somewhat easier, including integration with git and gem. This makes my life easier in all my dependent projects.
  - Skipped a couple of version numbers working out the rake integration :).

Fixes:

  - Added or fixed the general documentation for printing functionality.

## 0.3.1 (March 25, 2011)

Features:

  - Refactored the version class to be easier to integrate with rake and dependent projects, if they want.
  - Added some minor integration with rake for versioning assets.

## 0.3.0 (March 24, 2011)

Features:

  - Added the basic manpage printing.
  - Added a <code>default</code> directive to the <code>SuperCommand</code> to allow for default commands.
  - Added <code>:option_styles</code> directive to the manpage and standard printers.


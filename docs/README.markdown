# Choosy: Picking your arguments carefully

This is a small DSL library for creating command line clients in Ruby. It is largely inspired by the <a href="https://github.com/defunkt/choice">choice</a>, <a href="https://github.com/visionmedia/commander">commander</a>, and <a href="http://furius.ca/optcomplete/">optcomplete.py</a> libraries, though it makes some different design decisions than they do.  It is opinionated software.

This library should:

  - Make creating command line clients relatively easy.
  - Make creating supercommands like git, subversion, and gem easier.
  - Allow you to add validation logic for your arguments within the parsing phase.
  - Allowing for dependencies between options, so that you can more easily validate related options (i.e. if the<code>--bold</code> flag requires the <code>--font Arial</code> flag, then you should be able to ask for the <code>--font</code> option to be validated first, and then the <code>--bold</code> option.
  - Allow you to customize its output using your own formatting system.
  - Allow you to customize the output to your specifications.

This library should never:

  - Interact with your execution logic.  You can attach executors to commands for convenience, but the execution phase should be delegated to you, not the parsing library.  Separation of concerns, people.
  - Rely on display or user interface libraries like Highline, since this is only for parsing command lines.
  - Pollute your namespaces with my DSL function names.  (I really, really hate it when libraries do this.) 

# Examples

>>> examples/foo.rb

### Super Commands

You can also combine multiple choices into an uber-choice, creating
commands that look a lot like git or subversion.

First, we create another command.

>>> examples/bar.rb
    
We can now create our super command.

>>> examples/superfoo.rb

### TODO: Output Printing

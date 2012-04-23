require 'tsort'
require 'time'
require 'date'
require 'yaml'

require 'choosy/errors'
require 'choosy/base_command'
require 'choosy/parse_result'
require 'choosy/parser'
require 'choosy/verifier'
require 'choosy/command'
require 'choosy/argument'
require 'choosy/option'
require 'choosy/terminal'
require 'choosy/converter'

require 'choosy/printing/base_printer'
require 'choosy/printing/color'

require 'choosy/dsl/base_builder'
require 'choosy/dsl/argument_builder'
require 'choosy/dsl/base_command_builder'
require 'choosy/dsl/command_builder'
require 'choosy/dsl/option_builder'

module Choosy
  autoload :SuperCommand, 'choosy/super_command'
  autoload :SuperParser,  'choosy/super_parser'
  autoload :Version,      'choosy/version'

  module Printing
    autoload :ERBPrinter,        'choosy/printing/erb_printer'
    autoload :FormattingElement, 'choosy/printing/formatting_element'
    autoload :HelpPrinter,       'choosy/printing/help_printer'
    autoload :Manpage,           'choosy/printing/manpage'
    autoload :ManpageFormatter,  'choosy/printing/manpage'
    autoload :ManpagePrinter,    'choosy/printing/manpage_printer'
  end

  module DSL
    autoload :SuperCommandBuilder, 'choosy/dsl/super_command_builder'
  end
end


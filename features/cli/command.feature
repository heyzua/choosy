Feature: CLI Commands
  As a user at the command line
  I want to execute commands with arguments.

  # Testing the basic examples/date-time 

  Scenario: User runs the date-time with no options
    Given the CLI tool 'examples/date-time'
    When I run it with no arguments
    Then I should see the current time, timezone at '-0700'

  Scenario: User runs the date-time with a boolean option
    Given the CLI tool 'examples/date-time'
    When I run it with the argument '-u'
    Then I should see the current time, timezone at 'UTC'

  Scenario: User runs the date-time with a string option
    Given the CLI tool 'examples/date-time'
    When I run it with the argument '-f %Y'
    Then it should print out the current year

  # Testing the examples/list-files

  Scenario: User runs list-files with a single argument
    Given the CLI tool 'examples/list-files'
    When I run it with the the argument './spec'
    Then it should print match './spec/spec_helpers.rb'

  Scenario: User runs list-files with the --version flag
    Given the CLI tool 'examples/list-files'
    When I run it with the the argument '--version'
    Then it should print out '1.0'

  Scenario: User runs list-files with the --help flag
    Given the CLI tool 'examples/list-files'
    When I run it with the the argument '--help'
    Then it should match 'Usage:'


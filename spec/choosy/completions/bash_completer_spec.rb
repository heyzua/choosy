require 'spec_helpers'
require 'choosy/completions/bash_completer'
require 'choosy/command'
require 'choosy/super_command'

module Choosy::Completions
  describe BashCompleter do
    context "when the environment is not set" do
      it "should not be supported" do
        BashCompleter.build.should be_nil
      end
    end

    context "when the environment is set" do
      before :each do
        ENV['COMP_WORDS'] = "this that other"
        ENV['COMP_LINE'] = "command this that other"
        ENV['COMP_POINT'] = '2'
        ENV['COMP_CWORD'] = '3'
      end

      it "should be supported" do
        BashCompleter.build.should_not be_nil
      end

      after :each do
        ENV['COMP_WORDS'] = nil
        ENV['COMP_LINE'] = nil
        ENV['COMP_POINT'] = nil
        ENV['COMP_CWORD'] = nil
      end
    end

    it "should be able to find the current word being querried" do
      bash = BashCompleter.new(['a', 'b', 'c'], 'a b c', 3, 1)
      bash.current_word.should eql('b')
    end

    context "for commands" do
      before :each do
        @cmd = Choosy::Command.new :cmd do
          integer :count, "Count"
          boolean :bold, "Bold"
          string_ :parser, "Parser"
          string_ :Peaches, "Peaches"
        end
      end

      it "should allow for finding all of the options" do
        bash = BashCompleter.new(['-'], "-", 1, 0)
        bash.complete_for(@cmd).should eql(['-c', '--count', '-b', '--bold', '--parser', '--peaches'])
      end

      it "should allow for finding the long options" do
        bash = BashCompleter.new(['--'], "--", 1, 0)
        bash.complete_for(@cmd).should eql(['--count', '--bold', '--parser', '--peaches'])
      end

      it "should allow for finding options that have been partially specified" do
        bash = BashCompleter.new(['--p'], '--p', 1, 0)
        bash.complete_for(@cmd).should eql(['--parser', '--peaches'])
      end

      it "should return all the options when there are no words" do
        bash = BashCompleter.new([], '', 0, 0)
        bash.complete_for(@cmd).should eql(['-c', '--count', '-b', '--bold', '--parser', '--peaches'])
      end
    end

    context "for super commands" do
      before :each do
        @super = Choosy::SuperCommand.new :super do 
          integer :count, "Count"
          help

          command :foo do
            string_ :frobination, "Frobinator"
            symbol :flisterburg, "Nonsense!"
          end

          command :bar do
            string :tiddly_winks, "Game the system!"
          end
        end
      end

      it "should allow for finding all the global options" do
        bash = BashCompleter.new(['-'], "-", 1, 0)
        bash.complete_for(@super).should eql(['-c', '--count', '-h', '--help'])
      end

      it "should allow for finding all of the long options" do
        bash = BashCompleter.new(['--'], "--", 1, 0)
        bash.complete_for(@super).should eql(['--count', '--help'])
      end

      context "when subcommands are present" do
        it "should allow subcommand options" do
          bash = BashCompleter.new(['foo', '--'], "foo --", 5, 1)
          bash.complete_for(@super).should eql(['--count', '--help', '--frobination', '--flisterburg'])
        end

        it "should not allow previous subcommands options" do
          bash = BashCompleter.new(['bar', '-t', 'foo', '-'], "bar -t foo -", 5, 3)
          bash.complete_for(@super).should eql(['-c', '--count', '-h', '--help', '--frobination', '-f', '--flisterburg'])
        end

        it "should list the commands and the options when there are no words" do
          bash = BashCompleter.new([], '', 0, 0)
          bash.complete_for(@super).should eql(['foo', 'bar', '-c', '--count', '-h', '--help'])
        end
      end
    end
  end
end

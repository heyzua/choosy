module Choosy::Printing
  describe BasePrinter do
    before :each do
      @s = Choosy::SuperCommand.new(:super)
      @sb = @s.builder
      @c = Choosy::Command.new(:cmd, @s)
      @cb = @c.builder 
      @p = BasePrinter.new({})
    end

    describe "for the usage line" do
      it "should format a full boolean option" do
        o = @cb.boolean :bold, "bold"
        @p.usage_option(o).should eql("[-b|--bold]")
      end

      it "should format a partial boolean option" do
        o = @cb.boolean_ :bold, "bold"
        @p.usage_option(o).should eql('[--bold]')
      end

      it "should format a short boolean option" do
        o = @cb.option :bold do
          short '-b'
        end
        @p.usage_option(o).should eql('[-b]')
      end

      it "should format a negation of a boolean option" do
        o = @cb.boolean :bold, "Bold!!" do
          negate 'un'
        end
        @p.usage_option(o).should eql('[-b|--bold|--un-bold]')
      end

      it "should format a full single option" do
        o = @cb.single :color, "color"
        @p.usage_option(o).should eql('[-c|--color=COLOR]')
      end

      it "should format a parial boolean option" do
        o = @cb.single_ :color, "color"
        @p.usage_option(o).should eql('[--color=COLOR]')
      end
      
      it "shoudl format a full multiple option" do 
        o = @cb.multiple :colors, "c"
        @p.usage_option(o).should eql('[-c|--colors COLORS+]')
      end

      it "should format a partial multiple option" do
        o = @cb.multiple_ :colors, "c"
        @p.usage_option(o).should eql('[--colors COLORS+]')
      end
    end

    describe "for the option line" do
      it "should format a full boolean option" do
        o = @cb.boolean :bold, "b"
        @p.regular_option(o).should eql('-b, --bold')
      end

      it "should format a partial boolean option" do
        o = @cb.boolean_ :bold, "b"
        @p.regular_option(o).should eql('    --bold')
      end

      it "should format a short boolean option" do
        o = @cb.option :bold do |b|
          b.short '-b'
        end

        @p.regular_option(o).should eql('-b')
      end

      it "should format a negation of an option" do
        o = @cb.boolean :bold, "Bold" do
          negate 'un'
        end

        @p.regular_option(o).should eql('-b, --[un-]bold')
      end

      it "should format a full single option" do
        o = @cb.single :color, "color"
        @p.regular_option(o).should eql('-c, --color COLOR')
      end

      it "should format a partial single option" do
        o = @cb.single_ :color, "color"
        @p.regular_option(o).should eql('    --color COLOR')
      end

      it "should format a full multiple option" do
        o = @cb.multiple :colors, "colors"
        @p.regular_option(o).should eql('-c, --colors COLORS+')
      end

      it "should format a partial multiple option" do
        o = @cb.multiple_ :colors, "colors"
        @p.regular_option(o).should eql('    --colors COLORS+')
      end
    end

    describe "formatting the command name" do
      it "should format the name with the supercommand" do
        @p.command_name(@c).should eql('super cmd')
      end

      it "should format the command" do
        @p.command_name(Choosy::Command.new(:name)).should eql('name')
      end

      it "should format the super command" do
        @p.command_name(@s).should eql('super')
      end
    end

    describe "formatting the full usage" do
      describe "for commands" do
        it "should add the default metaname" do
          @p.usage_wrapped(@c).should eql(['super cmd'])
        end

        it "should add an option if given" do
          @cb.boolean :bold, "Bold?"
          @p.usage_wrapped(@c).should eql(['super cmd [-b|--bold]'])
        end

        it "should add several options and wrap each line" do
          @cb.integer :bold, "bold"
          @cb.integer :long_method, "long"
          @cb.integer :here_it_goes, "here"
          @p.usage_wrapped(@c, ' ', 40).should eql(
['super cmd [-b|--bold=BOLD]',
 '           [-l|--long-method=LONG_METHOD]',
 '           [-h|--here-it-goes=HERE_IT_GOES]'])
        end

        it "should add the metaname" do
          @cb.arguments do
            metaname 'CMDS'
          end
          @p.usage_wrapped(@c).should eql(['super cmd CMDS'])
        end
      end
    end
  end
end


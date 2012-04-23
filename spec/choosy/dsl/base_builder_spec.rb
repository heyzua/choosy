module Choosy::DSL
  class FakeBuilder
    include BaseBuilder

    attr_reader :entity
    def initialize(mock)
      @entity = mock
    end
  end

  describe BaseBuilder do
    describe "external access calls" do
      module ExternalCaller
        attr_reader :called
        def call!
          @called = true
        end
        def called?
          @called ||= false
        end
      end

      include ExternalCaller

      it "should allow for external calls" do
        called?.should be(false)
        
        mock = mock()
        mock.should_receive(:finalize!)
        builder = FakeBuilder.new(mock)

        builder.evaluate! do
          call!
        end

        called?.should be(true)
      end
    end
  end
end

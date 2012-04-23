require 'tempfile'

module Choosy
  describe Version do
    before :each do
      version_file = File.join(File.dirname(__FILE__), 'version.yml')
      @version = Version.new(version_file)
    end

    describe "should be able to read" do
      it "the major version" do
        @version.major.should eql(5)
      end

      it "the minor version" do
        @version.minor.should eql(4)
      end

      it "the tiny verison" do
        @version.tiny.should eql(3)
      end
      
      it "the date" do
        @version.date.should eql('today')
      end
    end

    describe "attempting to load a file" do
      it "should allow you to specify a search path via a method" do
        version = Version.load_from_parent_parent_spec_choosy
        @version.should eql(version)
      end

      it "should allow you to specify the current directory" do
        version = Version.load_from_here
        @version.should eql(version)
      end

      it "should allow you to load from a specific directory" do
        version = Version.load_from_spec_choosy Dir.pwd
        @version.should eql(version)
      end
    end

    describe "while altering the config file" do
      before :each do
        @tmp = Tempfile.new('version.yml')
        @version.version_file = @tmp.path
      end

      after :each do
        @tmp.delete
      end

      it "should bump the major rev" do
        @version.version!(:major)
        @version.reload!
        @version.major.should eql(6)
      end

      it "should bump the minor rev" do
        @version.version!(:minor)
        @version.reload!
        @version.major.should eql(5)
      end

      it "should bump the tiny rev" do
        @version.version!(:tiny)
        @version.reload!
        @version.tiny.should eql(4)
      end

      it "should reset the tiny version when minor is bumped" do
        @version.version!(:minor)
        @version.reload!
        @version.tiny.should eql(0)
      end

      it "should reset the minor version when major is bumped" do
        @version.version!(:major)
        @version.reload!
        @version.minor.should eql(0)
      end

      it "should reset the tiny version when major is bumped" do
        @version.version!(:major)
        @version.reload!
        @version.tiny.should eql(0)
      end

      it "should reset the date" do
        now = Time.now
        @version.version!(:major)
        @version.reload!
        day, month, year = @version.date.split(/\//).map{|i|i.to_i}
        now.day.should be(day)
        now.month.should eql(month)
        now.year.should eql(year)
      end
    end
  end
end

require 'spec_helper'

describe CLI do
  describe "#test_command" do
    context "when -c option is passed" do
      it "should extract the test command from arguments" do
        CLI.new(%w(-c rake test)).test_command.should == 'rake test'
      end
    end

    context "when no -c option" do
      it "should return nil" do
        CLI.new(%w(--help meh)).test_command.should be_nil
        CLI.new([]).test_command.should be_nil
      end
    end
  end
end

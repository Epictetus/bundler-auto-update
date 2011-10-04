require 'spec_helper'

describe Gemfile do
  let(:gemfile) do
    Gemfile.new.tap { |gemfile|
      gemfile.stub!(:content) { content }
    }
  end

  describe "#gems" do
    subject { gemfile.gems }

    context "when emtpy Gemfile" do
      let(:content) { "" }

      it { should == [] }
    end

    context "when Gemfile contains 3 gems" do
      let(:content) { <<-EOF
source :rubygems

gem 'rails', "3.0.0"
 gem 'rake' , '< 0.9' 
gem 'mysql', :git => "git://...."
EOF
}

      its(:size) { should == 3 }

      describe "first gem" do
        subject { gemfile.gems.first }

        its(:name) { should == 'rails' }
        its(:version) { should == '3.0.0' }
        its(:options) { should be_nil }
      end

      describe "second gem" do
        subject { gemfile.gems[1] }

        its(:name) { should == 'rake' }
        its(:version) { should == '< 0.9' }
        its(:options) { should be_nil }
      end

      describe "last gem" do
        subject { gemfile.gems[2] }

        its(:name) { should == 'mysql' }
        its(:version) { should be_nil }
        its(:options) { should == ':git => "git://...."' }
      end
    end
  end # describe "#gems"
end

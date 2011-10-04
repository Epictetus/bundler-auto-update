require 'spec_helper'

describe Updater do
  describe "auto_update!" do
    let(:updatable_gem) { Dependency.new('rails', '3.0.0', nil) }
    let(:non_updatable_gem) { Dependency.new('rake', '<0.9') }
    let(:gems) { [updatable_gem, non_updatable_gem] }

    let(:updater) do
      Updater.new.tap do |updater|
        updater.gemfile.stub!(:gems) { gems }
      end
    end

    it "should update all auto_updatable" do
      updater.should_receive(:update).with(updatable_gem, :patch).and_return(true)
      updater.should_receive(:update).with(updatable_gem, :minor).and_return(false)
      updater.should_not_receive(:update).with(updatable_gem, :major)

      updater.should_not_receive(:update).with(non_updatable_gem, :patch)

      updater.auto_update!
    end
  end
end


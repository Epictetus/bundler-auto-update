require 'spec_helper'

describe GemUpdater do
  let(:gemfile) { Gemfile.new }
  let(:test_command) { '' }

  describe "auto_update" do

    context "when gem is updatable" do
      let(:gem_updater) { GemUpdater.new(Dependency.new('rails', '3.0.0', nil), gemfile, test_command) }

      it "should attempt to update to patch, minor and major" do
        gem_updater.should_receive(:update).with(:patch).and_return(true)
        gem_updater.should_receive(:update).with(:minor).and_return(false)
        gem_updater.should_not_receive(:update).with(:major)

        gem_updater.auto_update
      end
    end

    context "when gem is not" do
      let(:gem_updater) { GemUpdater.new(Dependency.new('rake', '<0.9'), gemfile, test_command) }

      it "should not attempt to update it" do
        gem_updater.should_not_receive(:update)

        gem_updater.auto_update
      end
    end
  end # describe "auto_update"

  describe "#update" do
    let(:gem) { Dependency.new('rails', '3.0.0', nil) }
    let(:gem_updater) { GemUpdater.new(gem, gemfile, test_command) }

    context "when no new version" do
      it "should return" do
        gem.should_receive(:last_version).with(:patch) { gem.version }
        gem_updater.should_not_receive :update_gemfile
        gem_updater.should_not_receive :run_test_suite

        gem_updater.update(:patch)
      end
    end

    context "when new version" do
      context "when tests pass" do
        it "should commit new version" do
          gem.should_receive(:last_version).with(:patch) { gem.version.next }
          gem_updater.should_receive(:update_gemfile).and_return true
          gem_updater.should_receive(:run_test_suite).and_return true
          gem_updater.should_receive(:commit_new_version).and_return true
          gem_updater.should_not_receive(:revert_to_previous_version)

          gem_updater.update(:patch)
        end
      end

      context "when tests do not pass" do
        it "should revert to previous version" do
          gem.should_receive(:last_version).with(:patch) { gem.version.next }
          gem_updater.should_receive(:update_gemfile).and_return true
          gem_updater.should_receive(:run_test_suite).and_return false
          gem_updater.should_not_receive(:commit_new_version)
          gem_updater.should_receive(:revert_to_previous_version)

          gem_updater.update(:patch)
        end
      end

      context "when it fails to upgrade gem" do
        it "should revert to previous version" do
          gem.should_receive(:last_version).with(:patch) { gem.version.next }
          gem_updater.should_receive(:update_gemfile).and_return false
          gem_updater.should_not_receive(:run_test_suite)
          gem_updater.should_not_receive(:commit_new_version)
          gem_updater.should_receive(:revert_to_previous_version)

          gem_updater.update(:patch)
        end
      end
    end
  end
end


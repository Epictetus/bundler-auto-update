require "bundler-auto-update/version"

module Bundler
  module AutoUpdate
    class CLI
      def initialize(argv)
        @argv = argv
      end

      def run!
        Update.new(test_command).auto_update!
      end

      protected

      # @todo spec
      def test_command
        # IMPLEMENT ME!
      end
    end

    class Updater
      DEFAULT_TEST_COMMAND = "rake"

      attr_reader :test_command

      def initialize(test_command = DEFAULT_TEST_COMMAND)
        @test_command = test_command
      end

      def auto_update!
        gemfile.gems.each do |gem|
          if gem.updatable?
            Logger.log "Updating #{name}."
            update(gem, :patch) and update(gem, :minor) and update(gem, :major)
          else
            Logger.log "#{name} is not auto-updatable, passing it."
          end
        end
      end

      def gemfile
        @gemfile ||= Gemfile.new
      end

      def update(gem, version_type)
        new_version = gem.last_version(version_type)

        if new_version == version
          Logger.log_indent "Current gem already at latest #{version_type} version. Passing this update."
          return
        end

        Logger.log_indent "Updating to #{version_type} version #{new_version}"

        gem.version = gem.new_version

        gemfile.update_gem(gem)

        if run_test
          Logger.log_indent "Test suite ran succesfully. Committing changes."
          commit_new_version(gem)
        else
          Logger.log_indent "Test suite failed to run. Reverting changes."
          revert_to_previous_version
        end
      end

      def commit_new_version(gem)
        run_cmd "git commit Gemfile Gemfile.lock -m 'Auto update #{gem.name} to version #{gem.new_version}'"
      end

      def revert_to_previous_version
        run_cmd "git reset --hard Gemfile Gemfile.lock"
      end

      def run_test
        run_cmd test_command
      end

      def run_cmd(cmd)
        Logger.log cmd

        system cmd
      end
    end # class Updater

    class Gemfile
      # @todo spec
      def self.gems
        # IMPLEMENT ME !
      end

      # @todo spec
      def self.update_gem(gem)
        # IMPLEMENT ME !
      end
    end # class Gemfile

    class Logger
      def self.log(msg, prefix = "")
        puts prefix + msg
      end
    end

    class Gem
      def last_version(version_type)
        # IMPLEMENT ME !
      end
    end # class Gem

  end # module AutoUpdate
end # module Bundler

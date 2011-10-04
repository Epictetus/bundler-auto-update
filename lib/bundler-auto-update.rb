require "bundler-auto-update/version"

module Bundler
  module AutoUpdate
    class CLI
      def initialize(argv)
        @argv = argv
      end

      def run!
        Updater.new(test_command).auto_update!
      end

      # @todo spec
      def test_command
        if @argv.first == '-c'
          @argv[1..-1].join(' ')
        end
      end
    end

    class Updater
      DEFAULT_TEST_COMMAND = "rake"

      attr_reader :test_command

      def initialize(test_command)
        @test_command = test_command || DEFAULT_TEST_COMMAND
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

      GEM_LINE_REGEX = /^\s*gem\s*['"](\w+)['"]\s*(,\s*['"](.+)['"])?\s*(,\s*(.*))?\n$/

      # @todo spec
      def gems
        gems = []

        content.each do |l|

          if match = l.match(GEM_LINE_REGEX)
            _, name, _, version, _, options = match.to_a
            gems << Gem.new(name, version, options)
          end
        end

        gems
      end

      # @todo spec
      def update_gem(gem)
        # IMPLEMENT ME !
      end

      private

      def content
        @content ||= File.read('Gemfile')
      end
    end # class Gemfile

    class Logger
      def self.log(msg, prefix = "")
        puts prefix + msg
      end
    end

    class Gem
      attr_reader :name, :version, :options

      def initialize(name, version, options)
        @name, @version, @options = name, version, options
      end
      def last_version(version_type)
        # IMPLEMENT ME !
      end
    end # class Gem

  end # module AutoUpdate
end # module Bundler

require "bundler_auto_update/version"

module Bundler
  module AutoUpdate
    class CLI
      def initialize(argv)
        @argv = argv
      end

      def run!
        Updater.new(test_command).auto_update!
      end

      def test_command
        if @argv.first == '-c'
          @argv[1..-1].join(' ')
        end
      end
    end # class CLI

    class Updater
      DEFAULT_TEST_COMMAND = "rake"

      attr_reader :test_command

      def initialize(test_command = nil)
        @test_command = test_command || DEFAULT_TEST_COMMAND
      end

      def auto_update!
        gemfile.gems.each do |gem|
          GemUpdater.new(gem, gemfile, test_command).auto_update
        end
      end

      def gemfile
        @gemfile ||= Gemfile.new
      end
    end

    class GemUpdater
      attr_reader :gem, :gemfile, :test_command

      def initialize(gem, gemfile, test_command)
        @gem, @gemfile, @test_command = gem, gemfile, test_command
      end

      def auto_update
        if updatable?
          Logger.log "Updating #{gem.name}"
          update(:patch) and update(:minor) and update(:major)
        else
          Logger.log "#{gem.name} is not auto-updatable, passing it."
        end
      end

      # @return [Boolean] true on success or when already at latest version
      def update(version_type)
        new_version = gem.last_version(version_type)

        if new_version == gem.version
          Logger.log_indent "Current gem already at latest #{version_type} version. Passing this update."

          return true
        end

        Logger.log_indent "Updating to #{version_type} version #{new_version}"

        gem.version = new_version

        if update_gemfile and run_test_suite and commit_new_version
          true
        else
          revert_to_previous_version
          false
        end
      end

      private

      def update_gemfile
        if gemfile.update_gem(gem) 
          Logger.log_indent "Gemfile updated successfully."
          true
        else
          Logger.log_indent "Failed to update Gemfile."
          false
        end
      end

      def run_test_suite
        Logger.log_indent "Running test suite"
        if CommandRunner.system test_command
          Logger.log_indent "Test suite ran successfully."
          true
        else
          Logger.log_indent "Test suite failed to run."
          false
        end
      end

      # @return true when the gem has a fixed version.
      def updatable?
        gem.version =~ /^\d+\.\d+\.\d+$/
      end

      def commit_new_version
        Logger.log_indent "Committing changes"
        CommandRunner.system "git commit Gemfile Gemfile.lock -m 'Auto update #{gem.name} to version #{gem.version}'"
      end

      def revert_to_previous_version
        Logger.log_indent "Reverting changes"
        CommandRunner.system "git checkout Gemfile Gemfile.lock"
        gemfile.reload!
      end
    end # class GemUpdater

    class Gemfile

      def gem_line_regex(gem_name = '(\w+)')
        /^\s*gem\s*['"]#{gem_name}['"]\s*(,\s*['"](.+)['"])?\s*(,\s*(.*))?\n?$/
      end

      # @note This funky code parser could be replaced by a funky dsl re-implementation
      def gems
        gems = []

        content.dup.each_line do |l|
          if match = l.match(gem_line_regex)
            _, name, _, version, _, options = match.to_a
            gems << Dependency.new(name, version, options)
          end
        end

        gems
      end

      # @todo spec
      def update_gem(gem)
        update_content(gem) and write and run_bundle_update(gem)
      end

      def content
        @content ||= read
      end

      def reload!
        @content = read
      end

      private

      def update_content(gem)
        new_content = ""
        content.each_line do |l|
          if l =~ gem_line_regex(gem.name)
            l.gsub!(/\d+\.\d+\.\d+/, gem.version)
          end

          new_content += l
        end

        @content = new_content
      end

      def read
        File.read('Gemfile')
      end

      def write
        File.open('Gemfile', 'w') do |f|
          f.write(content)
        end
      end

      def run_bundle_update(gem)
        CommandRunner.system("bundle install") or CommandRunner.system("bundle update #{gem.name}")
      end
    end # class Gemfile

    class Logger
      def self.log(msg, prefix = "")
        puts prefix + msg
      end

      def self.log_indent(msg)
        log(msg, "  - ")
      end

      def self.log_cmd(msg)
        log(msg, "    > ")
      end
    end

    class Dependency
      attr_reader :name, :options, :major, :minor, :patch
      attr_accessor :version

      def initialize(name, version = nil, options = nil)
        @name, @version, @options = name, version, options

        @major, @minor, @patch = version.split('.') if version
      end

      def last_version(version_type)
        case version_type
        when :patch
          available_versions.select { |v| v =~ /^#{major}\.#{minor}\D/ }.first
        when :minor
          available_versions.select { |v| v =~ /^#{major}\./ }.first
        when :major
          available_versions.first
        end
      end

      def available_versions
        the_gem_line = gem_remote_list_output.scan(/^#{name}\s.*$/).first
        the_gem_line.scan /\d+\.\d+\.\d+/
      end

      def gem_remote_list_output
        CommandRunner.run "gem list #{name} -r -a"
      end
    end # class Dependency

    class CommandRunner
      def self.system(cmd)
        Logger.log_cmd cmd

        Kernel.system cmd
      end

      def self.run(cmd)
        `#{cmd}`
      end
    end
  end # module AutoUpdate
end # module Bundler

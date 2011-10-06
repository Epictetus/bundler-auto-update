require File.expand_path('../lib/bundler_auto_update.rb', File.dirname(__FILE__))

include Bundler::AutoUpdate

# Stub out system commands
class Bundler::AutoUpdate::CommandRunner
  def self.system(cmd)
    puts "Stub! #{cmd}"

    true
  end

  def self.run(cmd)
    puts "Stub! #{cmd}"

    "command output"
  end
end

class Gemfile
  def read
    puts "Stub! read"

    true
  end

  def write
    puts "Stub! write"

    true
  end
end

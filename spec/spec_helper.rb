require File.expand_path('../lib/bundler_auto_update.rb', File.dirname(__FILE__))

include Bundler::AutoUpdate

# Stub out system commands
class Bundler::AutoUpdate::CommandRunner
  def self.system(cmd)
    puts "Stub! #{cmd}"
  end

  def self.run(cmd)
    puts "Stub! #{cmd}"
  end
end

require 'trollop'

require_relative 'asbo/logger'
require_relative 'asbo/build_manager'
require_relative 'asbo/constants'
require_relative 'asbo/project_config'
require_relative 'asbo/package_manager'
require_relative 'asbo/workspace_config'
require_relative 'asbo/dependency'
require_relative 'asbo/repo'
require_relative 'asbo/compiler'

module ASBO
  extend self

  COMMANDS = %w{pre-build post-build}

  def run(args)
    command = args.shift unless args.empty? || args.first.start_with?('-')

    command_str = COMMANDS.include?(command) ? command : nil
    parser = create_parser(command_str)

    case command
    when 'pre-build', 'post-build'
      parse_build_args(parser, command)
    end

    opts = Trollop::with_standard_exception_handling(parser) do
      raise Trollop::HelpNeeded unless COMMANDS.include?(command)
      parser.parse args
    end

    Logger.verbose = opts[:verbose]

    case command
    when 'pre-build'
      BuildManager.new(*opts.values_at(:arch, :abi, :config, :compiler, :project)).pre_build(opts) # HACKY - filter opts
    when 'post-build'
      BuildManager.new(*opts.values_at(:arch, :abi, :config, :compiler, :project)).post_build
    end
  end

  def create_parser(command)
    command_str = command ? command : "(" << COMMANDS.join('|') << ")"
    Trollop::Parser.new do 
      banner "Usage: #{File.basename(__FILE__)} #{command_str} [args]\n\n"
      banner "See #{File.basename(__FILE__)} <subcommand> --help for more details\n\n" unless command
      banner "Common arguments:"
      opt :verbose, "Be Verbose", :default => false, :short => 'v'
      stop_on COMMANDS
    end
  end

  def parse_build_args(parser, subcommand)
    parser.instance_eval do
      opt :arch, "Architecture you're building", :type => String, :required => true, :short => 'a'
      opt :abi, "ABI you're building", :type => String, :required => true, :short => 'b'
      opt :config, "Build configuration (e.g. Debug) you're building", :type => String , :required => true, :short => 'c'
      opt :compiler, "Compler you're building with. Valid values are #{Compiler::COMPILERS.join(', ')}", :type => String, :required => true, :short => 'o'
      opt :project, "Path to the project you're building", :type => String, :short => 'p'
      opt :linker, "Whether to generate linker options, and where to output them to. Use a filename or 'stdout'", :type => String
      opt :include, "Whether to generate include path options, and where to output them to. Use a filename or 'stdout'", :type => String
    end
  end
end

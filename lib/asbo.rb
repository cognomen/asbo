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
    default_opts = parse_common_args(args)

    command = args.shift

    opts = case command
    when 'pre-build'
      parse_build_args(args)
    when 'post-build'
      parse_build_args(args)
    else
      {}
    end

    opts = default_opts.merge(opts)
    Logger.verbose = opts[:verbose]

    case command
    when 'pre-build'
      BuildManager.new(opts[:arch], opts[:abi], opts[:config], opts[:compiler], opts[:project]).pre_build
    when 'post-build'
      BuildManager.new(opts[:arch], opts[:abi], opts[:config], opts[:compiler], opts[:project]).post_build
    else
      Trollop::die "Unknown command #{command}" if command && !COMMANDS.include?(command)
    end
  end

  def parse_common_args(args)
    opts = Trollop::options(args) do
      banner "Usage: #{File.basename(__FILE__)} (pre-build|post-build) [args]\n" <<
      "See #{File.basename(__FILE__)} <subcommand> --help for more details"
      opt :verbose, "Be Verbose", :default => false, :short => 'v'
      stop_on COMMANDS
    end
    opts
  end

  def parse_build_args(args)
    # Annoying default options have to be duplicated here.
    # TODO resolve

    opts = Trollop::options(args) do
      opt :arch, "Architecture you're building", :type => String, :required => true, :short => 'a'
      opt :abi, "ABI you're building", :type => String, :required => true, :short => 'b'
      opt :config, "Build configuration (e.g. Debug) you're building", :type => String , :required => true, :short => 'c'
      opt :compiler, "Compiler you're building with. Valid values are #{Compiler::COMPILERS.join(', ')}", :type => String, :required => true, :short => 'o'
      opt :project, "Path to the project you're building", :type => String, :short => 'p'
      opt :verbose, "Be Verbose", :default => false, :short => 'v'
    end
    opts
  end
end

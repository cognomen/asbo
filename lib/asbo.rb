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
require_relative 'asbo/app_error'

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

    Logger.be_verbose if opts[:verbose]
    Logger.be_quiet if opts[:quiet]
    Logger.add_file_logger(File.join(opts[:project] || Dir.getwd, 'asbo.log'))

    begin
      case command
      when 'pre-build'
        opts = prep_arch_abi_build_config(opts)
        BuildManager.new(*opts.values_at(:arch, :abi, :build_config, :compiler, :project)).pre_build(opts) # HACKY - filter opts
      when 'post-build'
        opts = prep_arch_abi_build_config(opts)
        BuildManager.new(*opts.values_at(:arch, :abi, :build_config, :compiler, :project)).post_build
      end
    rescue AppError => e
      Logger.logger.error e.message
      # Always print backtrace to file, and print to stderr if requested
      Logger.file_logger.error e.backtrace.join("\n")
      warn e.backtrace.join("\n") if opts[:backtrace]
    end
  end

  def prep_arch_abi_build_config(opts)
    raise AppError, "The compiler '#{opts[:compiler]}' requires that you pass the architecture" if Compiler.needs_arch?(opts[:compiler]) && !opts[:arch_given]
    raise AppError, "The compiler '#{opts[:compiler]}' requires that you pass the abi" if Compiler.needs_abi?(opts[:compiler]) && !opts[:abi_given]
    raise AppError, "The compiler '#{opts[:compiler]}' requires that you pass the build config" if Compiler.needs_build_config?(opts[:compiler]) && !opts[:build_config_given]

    opts[:arch] ||= Compiler.arch(opts[:compiler])
    opts[:abi] ||= Compiler.abi(opts[:compiler])
    opts[:build_config] ||= Compiler.build_config(opts[:compiler])

    opts
  end

  def create_parser(command)
    command_str = command ? command : "(" << COMMANDS.join('|') << ")"
    Trollop::Parser.new do 
      banner "Usage: #{File.basename(__FILE__)} #{command_str} [args]\n\n"
      banner "See #{File.basename(__FILE__)} <subcommand> --help for more details\n\n" unless command
      banner "Common arguments:"
      opt :verbose, "Be Verbose", :default => false, :short => 'v'
      opt :quiet, "Be quiet", :default => false, :short => 'q'
      opt :backtrace, "Show a backtrace on error", :default => false
      conflicts :verbose, :quiet
      stop_on COMMANDS
    end
  end

  def parse_build_args(parser, subcommand)
    parser.instance_eval do
      opt :arch, "Architecture you're building. Required for some compilers", :type => String, :short => 'a'
      opt :abi, "ABI you're building. Required for some compilers", :type => String, :short => 'b'
      opt :build_config, "Build configuration (e.g. Debug) you're building. Required for some compilers", :type => String, :short => 'c'
      opt :compiler, "Compler you're building with. Valid values are #{Compiler.compilers.join(', ')}", :type => String, :required => true, :short => 'o'
      opt :project, "Path to the project you're building", :type => String, :short => 'p'
      opt :bin, "Whether to generate binary (linker) options, and where to output them to. Use a filename or 'stdout'", :type => String
      opt :include, "Whether to generate library (include) path options, and where to output them to. Use a filename or 'stdout'", :type => String
    end
  end
end

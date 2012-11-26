module ASBO
  class BuildManager
    include Logger

    attr_accessor :verbose

    def initialize(arch, abi, build_config, compiler, project_dir=nil)
      project_dir ||= Dir.getwd
      @arch, @abi, @build_config, @compiler, @project_dir = arch, abi, build_config, compiler, project_dir
      @project_config = ProjectConfig.new(project_dir, arch, abi, build_config)
      @workspace_config = WorkspaceConfig.new(project_dir)
      @verbose = false
    end

    def pre_build(output_opts)
      log.info "Performing pre-build action"
      pacman = PackageManager.new(@workspace_config, @project_config)
      pacman.download_dependencies

      compiler = Compiler::factory(@compiler, pacman)
      
      output(output_opts[:linker], compiler.linker_opts) if output_opts[:linker]
      output(output_opts[:include], compiler.include_opts) if output_opts[:include]
      # compiler.prepare
    end

    def post_build
      log.info "Performing post-build action"
      pacman = PackageManager.new(@workspace_config, @project_config)
      version = ENV['VERSION'] || SOURCE_VERSION
      pacman.cache_project(version)
    end

    def output(dest, value)
      if dest.empty? || dest == 'stdout'
        puts value
      else
        File.open(dest, 'w'){ |f| f.write(value) }
      end
    end
  end
end

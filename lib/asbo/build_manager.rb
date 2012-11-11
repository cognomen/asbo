module ASBO
  class BuildManager
    include Logger

    attr_accessor :verbose

    def initialize(arch, abi, project_dir=nil)
      project_dir ||= Dir.getwd
      @arch, @abi, @project_dir = arch, abi, project_dir
      @project_config = ProjectConfig.new(project_dir, arch, abi)
      @workspace_config = WorkspaceConfig.new(project_dir)
      @verbose = false
    end

    def pre_build(compiler)
      log.info "Performing pre-build action"
      pacman = PackageManager.new(@workspace_config, @project_config)
      pacman.download_dependencies

      compiler = Compiler::factory(compiler, pacman)
      compiler.prepare
    end

    def post_build(build_config)
      log.info "Performing post-build action"
      pacman = PackageManager.new(@workspace_config, @project_config)
      version = ENV['VERSION'] || SOURCE_VERSION
      pacman.cache_project(build_config, version)

    end
  end
end

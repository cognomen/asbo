module ASBO
  class BuildManager
    include Logger

    attr_accessor :verbose

    def initialize(arch, abi, project_dir=nil)
      project_dir ||= Dir.getwd
      @arch, @abi, @project_dir = arch, abi, project_dir
      @project_config = ProjectConfig.new(File.join(project_dir, BUILDFILE), arch, abi)
      @workspace_config = WorkspaceConfig.new(project_dir)
      @verbose = false
    end

    def pre_build(compiler)
      log.info "Performing pre-build action"
      pacman = PackageManager.new(@workspace_config, @project_config)
      pacman.download_dependencies

      compiler = Compiler::factory(compiler, pacman)
      compiler.write_files

    end

    def post_build

    end
  end
end

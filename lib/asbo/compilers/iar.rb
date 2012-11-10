module ASBO::Compiler
  class IAR
    include ASBO::Logger

    def initialize(package_mananger)
      @pacman = package_mananger
      @dependencies = @pacman.project_config.dependencies
    end

    def write_files
      log.info "Include opts: #{include_opts(@dependencies)}"
      log.info "Linker opts: #{linker_opts(@dependencies)}"
    end

    def include_opts(deps)
      include_paths = deps.map{ |dep| @pacman.headers_path(dep) }.select{ |x| File.directory?(x) }
      include_paths.map{ |x| "-I'#{x}'" }.join(' ')
    end

    def linker_opts(deps)
      artifacts = deps.map{ |dep| Dir["#{@pacman.artifacts_path(dep)}/*.a"] }
      artifacts.flatten.map{ |x| "-L'#{x}'"}.join(' ')
    end
  end
end

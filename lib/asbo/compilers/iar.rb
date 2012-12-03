module ASBO::Compiler
  class IAR
    include ASBO::Logger

    def initialize(package_mananger)
      @pacman = package_mananger
      @dependencies = @pacman.all_dependencies
      @output_dir = @pacman.project_config.project_dir
    end
    
    def include_paths
      include_paths = @dependencies.map{ |dep| @pacman.headers_path(dep) }.select{ |x| File.directory?(x) }.uniq
      include_paths.each{ |x| log.debug "Looking for include targets in #{x}" }
      include_paths
    end

    def include_paths_str
     include_paths.map{ |x| %Q{-I"#{x}"} }.join(' ')
    end

    def bin_paths
      artifacts = @dependencies.map do |dep|
        log.debug "Looking for linker targets in #{@pacman.artifacts_path(dep)}"
        # Glob all .a files
        Dir["#{@pacman.artifacts_path(dep)}/*.a"]
      end
      artifacts.flatten.uniq
    end

    def bin_paths_str
      bin_paths.map{ |x| %Q{"#{x}"} }.join("\n")
    end
  end
end

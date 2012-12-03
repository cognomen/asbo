module ASBO::Compiler
  class Ruby
    include ASBO::Logger

    def initialize(package_mananger)
      @pacman = package_mananger
      @dependencies = @pacman.all_dependencies
      @output_dir = @pacman.project_config.project_dir
    end
    
    def include_paths
      include_paths = @dependencies.map{ |dep| @pacman.lib_path(dep) }.select{ |x| File.directory?(x) }.uniq
      include_paths.each{ |x| log.debug "Looking for include targets in #{x}" }
      include_paths
    end

    def include_paths_str
     include_paths.join(':')
    end

    def bin_paths
      bin_paths = @dependencies.map{ |dep| @pacman.binaries_path(dep) }.select{ |x| File.directory?(x) }.uniq
      include_paths.each{ |x| log.debug "Looking for bin targets in #{x}" }
      bin_paths
    end

    def bin_paths_str
      bin_paths.join(':')
    end
  end
end

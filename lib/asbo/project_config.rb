require 'yaml'

module ASBO
  class ProjectConfig
    include Logger

    attr_reader :arch, :abi, :project_dir

    def initialize(project_dir, arch, abi)
      @arch, @abi, @project_dir = arch, abi, project_dir
      buildfile = File.join(project_dir, BUILDFILE)
      raise "Can't find buildfile at #{File.expand_path(buildfile)}" unless File.file?(buildfile)
      @config = YAML::load_file(buildfile)
      raise "Invalid buildfile (no package specified)" unless @config && @config.has_key?('package')

      personal_buildfile = File.join(project_dir, PERSONAL_BUILDFILE)
      @config.merge!(YAML::load_file(personal_buildfile)) if File.file?(personal_buildfile)
    end

    def package
      @config['package']
    end

    def dependencies
      return [] unless @config['dependencies']
      @config['dependencies'].map{ |x| Dependency.new(*x.split(':', 3), @arch, @abi) }
    end

    def to_dep(build_config, version)
      Dependency.new(package, version, build_config, @arch, @abi)
    end


  end
end

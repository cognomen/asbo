require 'yaml'

module ASBO
  class ProjectConfig
    def initialize(buildfile, arch, abi)
      @arch, @abi = arch, abi
      raise "Can't find buildfile at #{File.expand_path(buildfile)}" unless File.file?(buildfile)
      @config = YAML::load_file(buildfile)
      raise "Invalid buildfile (no package specified)" unless @config && @config.has_key?('package')
    end

    def package
      @config['package']
    end

    def dependencies
      return [] unless @config['dependencies']
      @config['dependencies'].map{ |x| Dependency.new(*x.split(':', 3), @arch, @abi) }
    end


  end
end

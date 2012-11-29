require 'yaml'

module ASBO
  class ProjectConfig
    include Logger

    attr_reader :arch, :abi, :project_dir, :build_config

    def initialize(project_dir, arch, abi, build_config)
      @arch, @abi, @build_config, @project_dir = arch, abi, build_config, project_dir
      buildfile = File.join(project_dir, BUILDFILE)
      raise AppError,  "Can't find buildfile at #{File.expand_path(buildfile)}" unless File.file?(buildfile)
      # @config = YAML::load_file(buildfile)
      @config = IniParser.new(buildfile).load
      raise AppError,  "Invalid buildfile (no project specified)" unless @config['project.name']

      # personal_buildfile = File.join(project_dir, PERSONAL_BUILDFILE)
      # @config.merge!(YAML::load_file(personal_buildfile)) if File.file?(personal_buildfile)
    end

    def project
      @config['project.name']
    end

    def packages
      @config.find_sections(/^package\..*$/)
    end

    def dependencies
      deps = []
      dep_config = @config.get('project.depends', [])
      dep_config.push(*packages.map{ |_,p| p[:depends] || [] })

      return [] unless dep_config
      dep_config.map do |x|
        project, config, version = x.split(/\s*:\s*/, 3)
        # Allow them to skip the config bit
        if version.nil?
          version, config = config, @build_config
        elsif config.empty?
          config = @build_config
        end
        Dependency.new(project, version, config, @arch, @abi)
      end
    end

    def publish_rules
      return {} unless @config['publish']
      Hash[@config['publish'].map{ |x| x.split(/\s*=>\s*/) }]
    end

    def to_dep(build_config, version)
      Dependency.new(package, version, build_config, @arch, @abi)
    end
  end
end

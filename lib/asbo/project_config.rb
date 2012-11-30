require 'yaml'

module ASBO
  class ProjectConfig
    include Logger

    attr_reader :arch, :abi, :project_dir, :build_config
    attr_accessor :package # Allow them to set this afterwards

    def initialize(project_dir, arch, abi, build_config, package)
      @arch, @abi, @build_config, @project_dir, @package = arch, abi, build_config, project_dir, package
      buildfile = File.join(project_dir, BUILDFILE)
      raise AppError,  "Can't find buildfile at #{File.expand_path(buildfile)}" unless File.file?(buildfile)
      @config = IniParser.new(buildfile).load
      raise AppError,  "Invalid buildfile (no project specified)" unless @config['project.name']

      # Use the first package if there's only one
      @package ||= packages.length == 1 ? packages.first : nil

      # personal_buildfile = File.join(project_dir, PERSONAL_BUILDFILE)
      # @config.merge!(YAML::load_file(personal_buildfile)) if File.file?(personal_buildfile)
    end

    def project
      @config['project.name']
    end

    def packages
      @config.find_sections(/^package\..*$/).map{ |k,_| k.to_s.sub(/^package\./, '') }
    end

    def project_package
      project + (@package ? "-#{@package}" : '')
    end

    def dependencies
      dep_config = package.nil? ? @config.get('project.depends', []) : @config.get("package.#{@package}.depends", [])

      return [] unless dep_config
      [*dep_config].map do |x|
        project, config, version = x.split(/\s*:\s*/, 3)
        # Allow them to skip the config bit
        if version.nil?
          version, config = config, @build_config
        elsif config.empty?
          config = @build_config
        end
        Dependency.new(project, @package, version, config, @arch, @abi)
      end
    end

    def publish_rules
      rules = [*@config.get('project.publish', [])]
      rules.push(*@config.get("package.#{@package}.publish", [])) if @package
      p rules
      Hash[rules.map{ |x| x.split(/\s*=>\s*/) }]
    end

    def to_dep(build_config, version)
      Dependency.new(project, @package, version, build_config, @arch, @abi)
    end
  end
end

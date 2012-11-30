module ASBO
  class Dependency
    attr_reader :project, :package, :version, :build_config, :arch, :abi

    def initialize(project, package, version, build_config, arch, abi)
      @project, @package, @version, @build_config, @arch, @abi = project, package, version, build_config, arch, abi
    end

    def project_package
      @project + (@package ? "-#{@package}" : '')
    end

    def is_source?
      @version == SOURCE_VERSION
    end

    def is_latest?
      @version == LATEST_VERSION
    end

    def to_s
      "#{project_package}-#{@version}" 
    end
  end
end

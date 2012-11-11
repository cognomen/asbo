require 'zip/zip'

module ASBO
  class PackageManager
    include Logger

    attr_reader :workspace_config, :project_config

    def initialize(workspace_config, project_config)
      @workspace_config, @project_config = workspace_config, project_config
    end

    def download_dependencies(project_config=nil)
      project_config ||= @project_config
      log.info "Resolving dependencies for #{project_config.package}..."
      project_config.dependencies.each do |dep|
        log.debug "Processing dependency #{dep}"
        if dep.is_source?
          process_source_dep(dep)
        else
          process_package_dep(dep)
        end
      end
    end

    def process_source_dep(dep)
      if dep_downloaded?(dep)
        log.debug "Source dependency #{dep} found"
      else
        raise "#{@project_config.package} specifies #{dep} as a dependency. This is a source dependency, so you need to build it"
      end
    end

    def process_package_dep(dep)
      if dep_downloaded?(dep)
        log.debug "Package dependency #{dep} is already downloaded"
      else
        download_dep(dep)
      end
    end

    def download_dep(dep)
      log.info "Downloading #{dep}"
      source = @workspace_config.package_source(dep.package, 'release', dep.version)
      log.debug "Downloading from #{source}"
      repo = Repo.factory(@workspace_config, source)
      file = repo.download
      log.info "Extracting #{dep}"
      extract_package(file, dep)
      # Now get recursive deps
      download_dependencies(ProjectConfig.new(File.join(dependency_path(dep), BUILDFILE), dep.arch, dep.abi))
    end

    def dep_downloaded?(dep)
      File.directory?(dependency_path(dep))
    end

    def dependency_path(dep)
      File.join(@workspace_config.cache_dir, "#{dep.package}-#{dep.version}")
    end

    def headers_path(dep)
      File.join(dependency_path(dep), 'inc')
    end

    def artifacts_path(dep)
      File.join(dependency_path(dep), "#{dep.arch}-#{dep.abi}-#{dep.build_config}", 'build')
    end

    def extract_package(path, dep)
      # Assume zip file contains name of package
      dest = File.dirname(dependency_path(dep))
      Zip::ZipFile.open(path) do |zf|
        zf.each do |e|
          file_dest = File.join(dest, e.name)
          FileUtils.mkdir_p(File.dirname(file_dest))
           log.debug "Extracting #{e.name} to #{file_dest}..."
           zf.extract(e.name, file_dest)
        end
      end
    end
  end
end

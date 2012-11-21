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

    def dep_downloaded?(dep)
      File.directory?(dependency_path(dep))
    end

    def dependency_path(dep)
     package_path(dep.package, dep.version)
    end

    def package_path(package, version)
       File.join(@workspace_config.cache_dir, "#{package}-#{version}")
    end

    def headers_path(dep)
      File.join(dependency_path(dep), 'inc')
    end

    def artifacts_path(dep)
      File.join(dependency_path(dep), 'bin', "#{dep.arch}-#{dep.abi}-#{dep.build_config}")
    end

    def cache_project(build_config, version)
      src = @project_config.project_dir
      dest = package_path(@project_config.package, version)

      log.info "Caching #{@project_config.package} to #{dest}"
      # TODO tell them how to nuke this, when we implement it
      log.warn "Overwriting previously-cached copy of version #{version}" if File.directory?(dest) && version != SOURCE_VERSION

      package_project(src, dest)
    end

    # dest should point to dir in which to put things
    def package_project(source, dest)
      FileUtils.mkdir_p(dest)
      FileUtils.cp(File.join(source, BUILDFILE), File.join(dest, BUILDFILE))
      cp_if_exists(source, dest, 'inc')
      cp_if_exists(source, dest, 'bin')
    end

    private

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
      type = dep.is_latest? ? 'latest' : 'release'
      repo = Repo.factory(@workspace_config, dep.package, type, dep.version)
      file = repo.download
      log.info "Extracting #{dep}"
      extract_package(file, dep)
      # Now get recursive deps
      download_dependencies(ProjectConfig.new(dependency_path(dep), dep.arch, dep.abi))
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

    def cp_if_exists(source, dest, folder)
      src = File.join(source, folder)
      dst = File.join(dest, folder)
      return unless File.exist?(src)

      log.debug "Copying #{src} to #{dst}"
      FileUtils.cp_r(src, dst)
    end
  end
end

module ASBO::Repo
  class File
    include ASBO::Logger

    def initialize(workspace_config, source, package, type, version)
      path = source['path']
      vars = {
        'package' => package,
        'version' => version,
      }
      path = workspace_config.resolve_vars_in_str(path, vars)
      @path = ::File.expand_path(::File.join(workspace_config.workspace, path)) << '.zip'
      log.debug "Got path: #{@path}"
    end

    def download
      raise AppError,  "Can't find package source #{@source}" unless ::File.file?(@path)
      @path
    end
  end
end

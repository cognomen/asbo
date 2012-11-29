require 'fileutils'

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
      @path = ::File.expand_path(::File.join(workspace_config.workspace, path))
      log.debug "Got path: #{@path}"
    end

    def download
      raise AppError,  "Can't find package source #{@source}" unless ::File.file?(@path)
      @path
    end

    def publish(file, overwrite=false)
      log.debug "Publishing #{@path}"

      begin
       FileUtils.mkdir_p(::File.dirname(@path))
      rescue SystemCallError => e
        raise ASBO::AppError, "Failed to create dir: #{e.message}"
      end

      exists = ::File.file?(::File.basename(@path))
      raise ASBO::AppError, "File #{@path} already exists. Use the appropriate flag to force overwriting" if exists && !overwrite

      log.debug "Uploading..."
      begin
        FileUtils.cp(file, ::File.basename(@path))
      rescue SystemCallError => e
        raise ASBO::AppError, "Failed to upload file #{@path}: #{e.message}"
      end
      log.info "Uploaded #{@path}"
    end
  end
end

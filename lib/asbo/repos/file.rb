module ASBO::Repo
  class File
    def initialize(workspace_config, source)
      @source = ::File.expand_path(::File.join(workspace_config.workspace, source))
    end

    def download
      raise "Can't find package source #{@source}" unless ::File.file?(@source)
      @source
    end
  end
end

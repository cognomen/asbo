module ASBO::Repo
  class File
    def initialize(source)
      @source = ::File.expand_path(source)
    end

    def download
      raise "Can't find package source #{@source}" unless ::File.file?(@source)
      @source
    end
  end
end

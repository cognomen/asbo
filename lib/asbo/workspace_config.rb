module ASBO
  class WorkspaceConfig
    include Logger

    def initialize(start_dir)
      @workspace = find_workspace(start_dir)
      proj_config = File.join(@workspace, PROJ_CONFIG)
      raise "Unable to find project config file (should be at #{proj_config})" unless File.file?(proj_config)
      @config = YAML::load_file(proj_config)
    end

    def cache_dir
      File.join(@workspace, CACHE_DIR)
    end

    def package_vars(package)
      # Check that key starts with $, but then strip it
      Hash[@config[package].select{ |k,v| k.start_with?('$') }.map{ |k,v| [k[1..-1], v] }]
    end

    def package_source(package)
      source = @config[package]['source'] || @config['default_source']
      raise "Could not find source for package #{package}" unless source
      source
    end

    private

    def find_workspace(start_dir)
      folder = File.expand_path(start_dir)
      until File.exists?(File.join(folder, WORKSPACE_INDICATOR)) do
        folder, old = File.expand_path(File.join(folder, '..')), folder
        raise "Unable to find workspace directory, starting at #{start_dir} (looking for #{WORKSPACE_INDICATOR})" if folder == old
      end
      folder
    end
  end
end

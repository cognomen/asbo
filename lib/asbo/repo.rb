require_relative 'repos/file'
require_relative 'repos/teamcity'
require_relative 'repos/ftp'

module ASBO
  module Repo
    def self.factory(workspace_config, package, version, type, purpose=:download)
      source = case purpose
      when :download
        workspace_config.package_source(package, type)
      when :publish
        workspace_config.package_publish_source(package, type)
      else
        raise AppError, "Unknown Repo factory type: #{type}"
      end

      driver = source['driver']
      raise AppError,  "You must specify the driver in sources.yml" unless driver

      case driver
      when 'file'
        Repo::File.new(workspace_config, source, package, type, version)
      when 'teamcity'
        Repo::TeamCity.new(workspace_config, source, package, type, version)
      when 'ftp'
        Repo::FTP.new(workspace_config, source, package, type, version)
      else
        raise AppError,  "Unknown driver '#{driver}' for source #{source}"
      end
    end
  end
end

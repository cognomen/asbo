require_relative 'repos/file'

module ASBO
  module Repo
    def self.factory(workspace_config, source)
      schema, source = source.match(/^(.*?):\/\/(.*)/).captures
      source << '.zip'

      case schema
      when 'file'
        Repo::File.new(workspace_config, source)
      else
        raise "Unknown schema '#{schema}' for source #{source}"
      end
    end
  end
end

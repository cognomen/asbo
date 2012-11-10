require_relative 'repos/file'

module ASBO
  module Repo
    def self.factory(source)
      schema, source = source.match(/^(.*?):\/\/(.*)/).captures
      source << '.zip'

      case schema
      when 'file'
        Repo::File.new(source)
      else
        raise "Unknown schema '#{schema}' for source #{source}"
      end
    end
  end
end

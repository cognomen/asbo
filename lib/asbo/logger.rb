require 'logger'

module ASBO
  module Logger
    def log
      Logger.logger
    end

    def self.logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def self.verbose=(value)
      self.log.level = value ? Logger::VERBOSE : Logger::INFO
    end

    def self.included(klass)
      klass.extend(self)
    end
  end
end

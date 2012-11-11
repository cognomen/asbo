require 'logger'

module ASBO
  module Logger
    def log
      Logger.logger
    end

    def self.logger
      @logger ||= ::Logger.new(STDOUT)
      @logger.log.level = Logger::INFO
      @logger
    end

    def self.verbose=(value)
      self.log.level = value ? Logger::DEBUG : Logger::INFO
    end

    def self.included(klass)
      klass.extend(self)
    end
  end
end

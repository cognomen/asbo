require 'logger'

module ASBO
  module Logger
    def log
      Logger.logger
    end

    def self.logger
      return @logger if @logger

      @logger = ::Logger.new(STDOUT)
      @logger.level = ::Logger::INFO
      @logger.formatter = Proc.new do |severity, datetime, progname, msg|
        severity = "[#{severity}]".ljust(7)
        "#{severity}: #{msg}\n"
      end
      @logger
    end

    def self.verbose=(value)
      self.logger.level = value ? ::Logger::DEBUG : ::Logger::INFO
    end

    def self.included(klass)
      klass.extend(self)
    end
  end
end

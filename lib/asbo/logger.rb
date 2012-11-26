require 'logger'

module ASBO
  module Logger
    def log
      Logger.logger
    end

    def self.logger
      return @logger if @logger

      @logger = MultiLogger.new
      @logger.add_logger(stdout_logger)

      @logger
    end

    def self.stdout_logger
      return @stdout_logger if @stdout_logger

      @stdout_logger = ::Logger.new(STDERR)
      @stdout_logger.level = ::Logger::INFO
      @stdout_logger.formatter = Proc.new do |severity, datetime, progname, msg|
        severity = "[#{severity}]".ljust(7)
        "#{severity}: #{msg}\n"
      end

      @stdout_logger
    end

    def self.verbose=(value)
      # This only affects the stdout_logger - other file loggers are always DEBUG
      stdout_logger.level = value ? ::Logger::DEBUG : ::Logger::INFO
    end

    def self.add_file_logger(file)
      file_logger = ::Logger.new(file, 1, 1024000)
      file_logger.level = ::Logger::DEBUG
      file_logger.formatter = Proc.new do |severity, datetime, progname, msg|
        severity = "[#{severity}]".ljust(7)
        "#{datetime.strftime('%FT%R')} #{severity}: #{msg}\n"
      end
      logger.add_logger(file_logger)
    end

    def self.included(klass)
      klass.extend(self)
    end

    # Thanks to https://gist.github.com/3639600
    class MultiLogger
      def initialize(loggers=nil)
        @loggers = []

        Array(loggers).each { |logger| add_logger(logger) }
      end

      def add_logger(logger)
        @loggers << logger
      end

      def level=(level)
        @loggers.each { |logger| logger.level = level }
      end

      def close
        @loggers.map(&:close)
      end

      def add(level, *args)
        @loggers.each { |logger| logger.add(level, args) }
      end

      ::Logger::Severity.constants.each do |level|
        define_method(level.downcase) do |*args|
          @loggers.each { |logger| logger.send(level.downcase, *args) }
        end

        define_method("#{ level.downcase }?".to_sym) do
          @level <= ::Logger::Severity.const_get(level)
        end
      end
    end
  end
end

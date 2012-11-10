require_relative 'compilers/iar'

module ASBO
  module Compiler
    def self.factory(compiler, *args)
      case compiler
      when 'iar'
        Compiler::IAR.new(*args)
      else
        raise "Unknown compiler: #{compiler}"
      end
    end
  end
end

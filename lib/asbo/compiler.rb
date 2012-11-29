require_relative 'compilers/iar'
require_relative 'compilers/ruby'

module ASBO
  module Compiler
    COMPILERS = {
      'iar' => {
        :arch => 'arm',
        :abi => nil,
        :build_config => nil,
      },
      'ruby' => {
        :arch => 'ruby',
        :abi => 'ruby',
        :build_config => 'ruby',
      }
    }

    def self.factory(compiler, *args)
      case compiler
      when 'iar'
        Compiler::IAR.new(*args)
      when 'ruby'
        Compiler::Ruby.new(*args)
      else
        raise ASBO::AppError,  "Unknown compiler: #{compiler}"
      end
    end

    def self.compilers
      COMPILERS.keys
    end

    def self.needs_arch?(compiler)
      COMPILERS[compiler][:arch].nil?
    end

    def self.arch(compiler)
      COMPILERS[compiler][:arch]
    end

    def self.needs_abi?(compiler)
      COMPILERS[compiler][:abi].nil?
    end

    def self.abi(compiler)
      COMPILERS[compiler][:abi]
    end

    def self.needs_build_config?(compiler)
      COMPILERS[compiler][:build_config].nil?
    end

    def self.build_config(compiler)
      COMPILERS[compiler][:build_config]
    end
  end
end

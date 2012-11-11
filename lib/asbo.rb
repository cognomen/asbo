require_relative 'asbo/logger'
require_relative 'asbo/build_manager'
require_relative 'asbo/constants'
require_relative 'asbo/project_config'
require_relative 'asbo/package_manager'
require_relative 'asbo/workspace_config'
require_relative 'asbo/dependency'
require_relative 'asbo/repo'
require_relative 'asbo/compiler'

module ASBO
  extend self

  def run
    # BuildManager.new('arm', 'abi', 'test/proj_1').pre_build('iar')
    BuildManager.new('arm', 'abi', 'test/proj_1').post_build('Debug')
  end
end

ASBO.run

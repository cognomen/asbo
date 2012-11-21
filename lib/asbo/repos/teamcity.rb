require 'open-uri'
require 'nokogiri'

module ASBO::Repo
  class TeamCity
    include ASBO::Logger

    def initialize(workspace_config, source, package, type, version)
      url = source['url']
      user = source['username']
      pass = source['password']
      project = source['project']

      teamcity_package = source['package'] ? workspace_config.resolve_config_vars(source['package'], {}, package) : package
      log.debug "Using teamcity package #{teamcity_package}"

      bt = fetch_bt(url, project, teamcity_package, user, pass)
      log.debug "Got BT: #{bt}"
    end

    def fetch_bt(url, project, package, user, pass)
      projects_url = url + '/httpAuth/app/rest/projects'
      log.debug "Looking for projects: #{projects_url}"
      node = Nokogiri::XML(open(projects_url, :http_basic_authentication => [user, pass])).css('project').find{ |x| x['name'] == project }
      raise "Can't find teamcity project #{project}" unless node
      project_url = url + node['href']
      log.debug "Looking for BT: #{project_url}"
      node = Nokogiri::XML(open(project_url, :http_basic_authentication => [user, pass])).css('buildType').find{ |x| x['name'] == package }
      raise "Can't find teamcity package #{package}" unless node
      node['id']
    end

    def download
      raise "Not yet implemented"
    end
  end
end

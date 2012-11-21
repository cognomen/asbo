require 'open-uri'
require 'uri'
require 'nokogiri'

module ASBO::Repo
  class TeamCity
    include ASBO::Logger

    def initialize(workspace_config, source, package, type, version)
      url = source['url']
      parsed = URI::parse(url)
      user, pass = parsed.user, parsed.password
      # Hacky, but CBA to reconstruct URl
      url.gsub!("#{user}:#{pass}@", '')
      project = source['project']

      teamcity_package = source['package'] ? workspace_config.resolve_config_vars(source['package'], {}, package) : package
      log.debug "Using teamcity package #{teamcity_package}"

      bt = fetch_bt(url, project, teamcity_package, user, pass)
      log.debug "Got BT: #{bt}"
    end

    def fetch_bt(url, project, package, user, pass)
      projects_url = url + '/httpAuth/app/rest/projects'
      log.debug "Looking for projects: #{projects_url}"
      node = Nokogiri::HTML(open(projects_url, :http_basic_authentication => [user, pass])).css('project').first{ |x| x['name'] == project }
      raise "Can't find teamcity project #{project}" unless node
      project_url = url + node['href']
      log.debug "Looking for BT: #{project_url}"
      node = Nokogiri::HTML(open(project_url, :http_basic_authentication => [user, pass])).css('buildtypes').first{ |x| x['name'] == package }
      raise "Can't find teamcity package #{package}" unless node
      node['id']
    end

    def download
      raise "Not yet implemented"
    end
  end
end

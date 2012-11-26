require 'open-uri'
require 'uri'
require 'tempfile'
require 'nokogiri'

module ASBO::Repo
  class TeamCity
    include ASBO::Logger

    def initialize(workspace_config, source, package, type, version)
      @type, @version = type, version

      args = {
        'package' => package,
      }
      source = workspace_config.resolve_config_vars(source, args, package)

      @url = source['url']
      @user = source['username']
      @pass = source['password']
      @project = source['project']
      
      @teamcity_package = source['package'] ? workspace_config.resolve_config_vars(source['package'], args,  package) : package
      log.debug "Using teamcity package #{@teamcity_package}"
    end

    def download
      bt = fetch_bt(@project, @teamcity_package)
      log.debug "Got BT: #{bt}"

      case @type
      when 'release'
        url = get_release_url(bt, @version, @teamcity_package)

      else
        raise AppError,  "Currently unsupported build type #{type}"
      end

      log.debug "Downloading from #{url}"

      file = Tempfile.new([@teamcity_package, '.zip'])
      file.binmode
      begin
        open(url, 'rb', :http_basic_authentication => [@user, @pass]) do |read_file|
          file.write(read_file.read)
        end
      ensure
        file.close
      end

      log.debug "Downloaded to #{file.path}"
      file.path
    end

    def fetch_bt(project, package)
      projects_url = @url + '/httpAuth/app/rest/projects'
      log.debug "Looking for projects: #{projects_url}"
      log.debug "Using teamcity project #{project}"
      node = Nokogiri::XML(open(projects_url, :http_basic_authentication => [@user, @pass])).css('project').find{ |x| x['name'] == project }
      raise AppError,  "Can't find teamcity project #{project}" unless node
      project_url = @url + node['href']
      log.debug "Looking for BT: #{project_url}"
      node = Nokogiri::XML(open(project_url, :http_basic_authentication => [@user, @pass])).css('buildType').find{ |x| x['name'] == package }
      raise AppError,  "Can't find teamcity package #{package}" unless node
      node['id']
    end

    def get_release_url(bt, version, package)
      builds_url = @url + "/httpAuth/app/rest/buildTypes/id:#{bt}/builds"
      node = Nokogiri::XML(open(builds_url, :http_basic_authentication => [@user, @pass])).css('build').find{ |x| x['number'] == version }
      raise AppError,  "Unable to find build number #{version}" unless node
      id = node['id']
      URI::escape(@url + "/httpAuth/app/rest/builds/id:#{id}/artifacts/files/#{package}-#{version}.zip")
    end
  end
end

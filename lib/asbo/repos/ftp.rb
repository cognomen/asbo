require 'net/ftp'
require 'uri'

module ASBO::Repo
  class FTP
    include ASBO::Logger

    def initialize(workspace_config, source, package, type, version)
      vars = {
        'package' => package,
        'version' => version,
      }

      source = workspace_config.resolve_config_vars(source, vars, package)
      url = source['url']
      parsed_url = URI::parse(url)
      @user = parsed_url.user || source['username'] || 'anonymous'
      @pass = parsed_url.password || source['password'] || ''
      @host = parsed_url.host
      @path = parsed_url.path

      log.debug "Got Host: #{@host}, Path: #{@path}, User: #{@user}"
    end

    def download
      file = Tempfile.new([@teamcity_package, '.zip'])
      file.binmode

      begin
        Net::FTP.open(@host) do |ftp|
          begin
            ftp.login(@user, @pass)
          rescue Net::FTPPermError => e 
            raise ASBO::AppError, "Failed to log in to ftp: #{e.message}"
          end
          ftp.passive = true
          log.debug "Logged in. Now downloading..."
          ftp.getbinaryfile(@path, nil, 1024) do |chunk|
            file.write(chunk)
          end
        end
      ensure
        file.close
      end

      log.debug "Downloaded to #{file.path}"
      file.path
    end

    def publish(file)
      log.debug "Publishing #{@path}"
      Net::FTP.open(@host) do |ftp|
        begin
          ftp.login(@user, @pass)
        rescue Net::FTPPermError => e 
          raise ASBO::AppError, "Failed to log in to ftp: #{e.message}"
        end
        log.debug "Logged in."
        ftp.passive = true
        begin
          ftp.chdir(::File.dirname(@path))
        rescue Net::FTPPermError => e
          if e.message[0, 3] == '550'
            log.debug "Creating dir: #{::File.dirname(@path)}"
            ftp.mkdir(::File.dirname(@path))
            ftp.chdir(::File.dirname(@path))
          else
            raise AppError, "Could not chdir, #{e.message}"
          end
        end

        log.debug "Uploading..."
        ftp.putbinaryfile(file, ::File.basename(@path))
        log.debug "Done"
      end
    end
  end
end

require 'rest_client'
require 'json'
require 'yaml'

class SofaCheck

  def initialize
    check_health(service, interval)
  end

  def check_health(service, interval)
    host = `hostname`.strip
    regex = service[0]
    name = "#{host}_#{service}"
    remainder = service[1..-1]
    process = run_command("ps aux | awk '/[#{regex}]#{remainder}/{print $2}'")

    if process.empty?
      # unhealthy
      data = {'name' => name, 'state' => 'unhealthy'}.to_json
    else
      # healthy
      data = {'name' => name, 'state' => 'healthy'}.to_json
    end

    RestClient.post("#{health_url}", data, {:content_type => :json, :authorization => "Token token=#{token}"})
  end

  def config
    YAML.load_file(ENV['HOME']+'/sofa.yml')
  end

  def token
    config["prod"]["access_token"]
  end

  def health_url
    config["prod"]["health_url"]
  end

  def service
    config["prod"]["service_name"]
  end

  def interval
    config["prod"]["service_interval"]
  end

  def run_command(cmd)
    `#{cmd}`
  end

end

SofaCheck.new

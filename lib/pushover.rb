module Pushover
  require 'thor'
  require 'psych'
  require "rushover"
  require "pushover/version"

  # Makes it nice and easy to send Pushover notifications
  class Pushover < Thor
    include Thor::Actions
    CONF_DIR = File.join(Dir.home, '.pushover')
    CONF_FILE = "#{CONF_DIR}/config.yml"
    CONF_DEFAULTS = { 'user_key' => '', 'api_token' => ''}
    HOST_NAME = %x(hostname).chomp

    method_option :priority, :aliases => "-p", :default => 0, :desc => '1: Urgent, 0: Ordinary, -1: No sound/vibe'
    method_option :title, :aliases => "-t", :default => "Message from #{HOST_NAME}"
    method_option :devise, :aliases => "-d"
    method_option :url
    method_option :url_title
    desc 'notify MSG', 'Send a Pushover notification!'
    def notify(message)
      initialize_config
      client = Rushover::Client.new(@config['api_token'])
      resp = client.notify(@config['user_key'], message, options)
      if resp.ok?
        say_status :ok, 'Notification sent!', :green
      else
        handle_error resp
      end
    rescue SocketError
      say_status :error, "Are you connected to the internetz?", :red
      exit 1
    end

  private
    def initialize_config
      if (File.exists? CONF_FILE)
        @config = Psych.load_file(CONF_FILE)
      else
        create_config
      end
    end

    def create_config
      if yes? "Config does not exist, do you want to create it?"
        create_file CONF_FILE, Psych.dump(CONF_DEFAULTS)
        say "Please fill in Pushover API key and your name!"
      else
        say_status :error, "Pushover needs a config to work!", :red
      end
      exit 1
    end

    def handle_error(resp)
      if resp[:user] == 'invalid' || resp[:token] == 'invalid'
        append = ', check config.yaml'
      end
      say_status :error, "#{resp[:errors].join()}#{append}", :red
    end
  end
end

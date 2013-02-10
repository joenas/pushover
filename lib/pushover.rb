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
    DEFAULT_TITLE = "Message from #{HOST_NAME}"

    method_option :priority, :aliases => "-p", :default => 0, :desc => '1: Urgent, 0: Ordinary, -1: No sound/vibe'
    method_option :title, :aliases => "-t", :desc => "your message's title, otherwise your app's name is used"
    method_option :devise, :aliases => "-d"
    method_option :url, :desc => 'a supplementary URL to show with your message'
    method_option :url_title, :desc => 'a title for your supplementary URL, otherwise just the URL is shown'

    desc 'notify MSG', "Send a Pushover notification! Try 'pushover help notify' for available options."
    def notify(message)
      @config = initialize_config
      send_notification message, options
    rescue SocketError
      say_status :error, "Are you connected to the internetz?", :red
      exit 1
    end

  private
    def send_notification message, options
      parse_options options

      client = Rushover::Client.new(@config['api_token'])
      @resp = client.notify(@config['user_key'], message, @params)
      if @resp.ok?
        say_status :ok, 'Notification sent!', :green
      else
        handle_error
      end
    end

    def parse_options frozen_hash
      @params = {}
      @params[:title] = frozen_hash[:title] || @config['default_title'] || DEFAULT_TITLE
      @params.merge frozen_hash
    end

    def initialize_config
      return Psych.load_file(CONF_FILE) if (File.exists? CONF_FILE)
      create_config_and_exit
    end

    def create_config_and_exit
      if yes? "Config does not exist, do you want to create it?"
        create_file CONF_FILE, Psych.dump(CONF_DEFAULTS)
        say "Please fill in Pushover API key and your name!"
      else
        say_status :error, "Pushover needs a config to work!", :red
      end
      exit 1
    end

    def handle_error
      if @resp[:user] == 'invalid' || @resp[:token] == 'invalid'
        append = ', check config.yaml'
      end
      say_status :error, "#{@resp[:errors].join()}#{append}", :red
    end
  end
end

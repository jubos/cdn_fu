require 'optparse'
require 'fileutils'

module CdnFu
  class CommandLine
    def initialize(args)
      @args = args
      @options = {}
    end

    def parse!
      begin
        @opts = OptionParser.new do |opts|
          opts.banner = 'Usage: cdnfu [configuration]'
          opts.on('-c', '--config CONFIG' , 'a ruby configuration file that tells cdn fu what to do') do |config|
            puts "Received Config File #{cfg}"
            @options[:config] = cfg
          end

          opts.on('--rails RAILS_DIR', "Install CDN Fu from the gem into a rails project as a plugin") do |dir|
            puts "Rails Install #{dir}"
            @options[:rails] = dir
          end

          opts.on_tail('-?','-h','--help', 'Show this message') do
            puts opts
            exit
          end
        end

        @opts.parse!(@args)

        # Check for required arguments
        if !@options[:config] && !@options[:rails]
          puts @opts
          exit
        end

        if @options[:config]
          if File.exists(@options[:config])
            eval(File.open(@options[:config]).read)
          else
            puts "Cannot find config file"
            exit
          end
        elsif @options[:rails]
        end
      rescue Exception => e
        exit
      end
    end
  end
end

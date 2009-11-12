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
          opts.banner = 'Usage: cdnfu [options]'
          opts.on('-c', '--config CONFIG' , 'a cdn fu configuration file') do |config|
            @options[:config] = config
          end

          opts.on('--rails RAILS_DIR', "Install CDN Fu from the gem into a rails project") do |dir|
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

        if config_file = @options[:config]
          if File.exists?(config_file)
            Dir.chdir(File.dirname(config_file))
            eval(File.open(config_file).read)
            Config.config.prepare_and_upload
          else
            puts "Cannot find config file"
            exit
          end
        elsif rails_dir = @options[:rails]
          plugins_dir = File.join(rails_dir,"vendor","plugins")
          unless File.exists?(plugins_dir)
            puts "#{plugins_dir} doesn't exist.  Are you sure this is a rails project?"
            exit
          end

          cdn_fu_dir = File.join(plugins_dir,'cdn_fu')

          if File.exists?(cdn_fu_dir)
            print "Directory #{cdn_fu_dir} already exists, overwrite [y/N]?"
            exit if gets !~ /y/i
            FileUtils.rm_rf(cdn_fu_dir)
          end

          tasks_dir = File.join(cdn_fu_dir,'tasks')

          begin 
            Dir.mkdir(cdn_fu_dir)
            Dir.mkdir(tasks_dir)
          rescue SystemCallError
            puts "Cannot create #{cdn_fu_dir}"
            exit
          end

          File.open(File.join(cdn_fu_dir,'init.rb'), 'w') do |file|
            file << File.read(File.dirname(__FILE__) + "/../../rails/init.rb")
          end

          File.open(File.join(tasks_dir,'cdn_fu.rake'),'w') do |file|
            file << "require 'cdn_fu/tasks'"
          end

          puts "CDN Fu plugin added to #{rails_dir}"
          exit
        end
      rescue RuntimeError => e
        puts e
        e.backtrace.each do |line|
          puts line
        end
        exit
      end
    end
  end
end

namespace "cdn" do
  desc "Initialize a cdn_fu.rb"
  task "init" => :environment do
    cfg_path = File.join(RAILS_ROOT,'config/cdn_fu.rb')
    if FileTest.exists?(cfg_path)
      puts "config/cdn_fu.rb already exists." 
      print "Do you want to overwrite? [y/n] "
      if STDIN.gets !~ /^[yY]/
        exit
      end
    end
    File.open(cfg_path,'w') do |f|
      f << <<-EOF
CdnFu::Config.configure do
  # asset_id
  # default: RAILS_ASSET_ID
  # The asset id that you need to increment whenever your assets change (for
  # cloudfront) This ensures that cloudfront assets are properly invalidated,
  # since there is no way to explicitly invalidate entries. Set it to nil if
  # you don't care about stale assets.
  #
  # Examples:
  # asset_id nil
  # asset_id '123'
  # asset_id File.open(File.join(RAILS_ROOT,'revision')) {|f| f.read.strip }
  # asset_id RAILS_ASSET_ID

  # asset_root_dir
  # default: RAILS_ROOT + 'public/'
  # This is where your files specifications will start looking for assets.

  # You can specify things to do before the minification step here.  For
  # example if you use Sass you will want to ensure you have the latest
  # stylesheets processed
  #
  #preprocess do
  #  Sass::Plugin.update_stylesheets
  #end

  files do 
    glob "javascripts/*.js", :minify => true, :gzip => true
    glob "stylesheets/*.css", :minify => true, :gzip => true
    glob "images/**/*.*"
  end
  
  # minifier
  # default: nil
  # YuiMinifier is the only included backend for now.  This will iterate over
  # each js/css asset and do a minification.
  # minifier YuiMinifier do 
  # yui_jar_path "/usr/bin/yuicompressor-2.4.2.jar"
  #end

  # uploader
  # default: nil
  #
  # Cloudfront is the only supported backend now. You can specify access
  # credentials in this file or for more safety, put them in your environment
  # variables CDN_FU_AMAZON_ACCESS_KEY and CDN_FU_AMAZON_SECRET_KEY environment
  # variables
  #uploader CloudfrontUploader do 
  #  s3_bucket 'mybucket'
  #  s3_access_key 'blah'
  #  s3_secret_key 'blah'
  #end
end
EOF
    end
  end

  desc "Uploads all your assets to your cdn"
  task "upload" => :environment do
    cfg_path = File.join(RAILS_ROOT,'config/cdn_fu.rb')
    if !FileTest.exists?(cfg_path)
      puts "#{cfg_path} doesn't exist.  Please run rake cdn:init to create a basic configuration file"
      exit
    end
    CdnFu.load_rails_config
    CdnFu::Config.config.prepare_and_upload
  end
end


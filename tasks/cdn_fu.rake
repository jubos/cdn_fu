namespace "cdn" do
  desc "Initialize a cdn_fu.rb"
  task "init" => :environment do
    cfg_path = File.join(RAILS_ROOT,'config/cdn_fu.rb')
    if !FileTest.exists?(cfg_path)
      File.open(cfg_path,'w') do |f|
        f << <<-EOF
CdnFuConfig.configure do |config|
  # The asset id that you need to increment whenever your assets change
  config.asset_id = "10"

  # You can specify things to do before the minification step here.  For
  # example if you use Sass you will want to ensure you have the latest
  # stylesheets processed
  #
  #config.preprocessor do
  #  Sass::Plugin.update_stylesheets
  #end
  
  # Here you can specify the minifier.  YuiMinifier is the only included one
  #config.minify(YuiMinifier) do |mini_cfg|
  # mini_cfg.yui_jar_path = "/usr/bin/yuicompressor-2.4.2.jar"
  #end

  # Finally specify the uploader.  Cloudfront is the only supported backend now
  # You can specify access credentials in this file or for more safety, put them in your environment variables
  # CDN_FU_AMAZON_ACCESS_KEY and CDN_FU_AMAZON_SECRET_KEY
  #config.uploader(CloudfrontUploader) do |uploader_cfg|
  #  uploader_cfg.s3_bucket = 'mybucket'
  #  uploader_cfg.s3_access_key = 'blah'
  #  uploader_cfg.s3_secret_key = 'blah'
  #end
end
EOF
      end
    end
  end

  desc "Uploads all your assets to your cdn"
  task "upload" => :environment do
    CdnFuConfig.prepare_and_upload
  end
end


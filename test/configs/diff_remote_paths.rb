CdnFu::Config.configure do |cfg|
  asset_id '1'
  asset_root_dir File.join(TEST_ROOT,'asset_root')

  files do 
    glob "js/*.js", :minify => true, :gzip => true, :path => '/javascripts'
    glob "images/**/*.png", :path => '/img'
  end
end

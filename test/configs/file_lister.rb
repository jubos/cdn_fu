CdnFu::Config.configure do |cfg|
  asset_id '1'
  asset_root_dir File.join(TEST_ROOT,'asset_root')

  files do 
    glob "js/*.js", :minify => true, :gzip => true
    glob "css/*.css", :minify => true, :gzip => true
    glob "images/**/*.png"
    file 'single/single.png', :path => '/s/s.png'
  end

  minifier YuiMinifier do
    yui_jar_path "/usr/bin/yuicompressor-2.4.2.jar"
  end

  upload do |file_list|
  end
end

CdnFu::Config.configure do
  tmp_dir File.join(TEST_ROOT,'/tmp/minified')
  asset_root_dir File.join(TEST_ROOT,'asset_root')

  files do 
    glob "js/*.js", :minify => true, :gzip => true
    glob "css/*.css", :minify => true, :gzip => true
    glob "images/**/*.png"
    file 'single/single.png', :path => '/s/s.png'
  end

  uploader LocalUploader do
    path File.join(TEST_ROOT, '/tmp/local_path')
  end
end

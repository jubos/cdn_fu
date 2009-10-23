require File.dirname(__FILE__) + '/../lib/cdn_fu'
require 'test/unit'

TEST_ROOT = File.dirname(File.expand_path(__FILE__))

# Change dir to this directory to ensure the test configs can be found
Dir.chdir(TEST_ROOT)

class TestBasic < Test::Unit::TestCase
  def setup
    CdnFu::Config.clear
  end

  def test_basic
    config = eval(File.open('configs/basic_cdn_fu_config.rb').read)
    assert_equal('1',config.asset_id)
    assert_equal('/tmp',config.tmp_dir)
    assert_nil(config.uploader)
  end

  def test_file_lister
    config = eval(File.open('configs/file_lister.rb').read)
    #config = eval'configs/file_lister.rb'
    assert_equal('1',config.asset_id)
    assert_equal(File.join(TEST_ROOT,'asset_root'),config.asset_root_dir)
    assert_equal(YuiMinifier,config.minifier.class)

    config.prepare_and_upload
    file_list = config.files
    assert_equal(8,file_list.size)
    assert_equal('/js/another.js',file_list[0].remote_path)
    assert(file_list[0].gzip?)
    assert(file_list[0].minify?)
  end

  def test_different_remote_paths
    config = eval(File.open('configs/diff_remote_paths.rb').read)
    config.prepare_and_upload
    file_list = config.files
    assert_equal(6,file_list.size)
    assert_equal('/javascripts/another.js',file_list[0].remote_path)
    assert_equal('/img/fun/fun.png',file_list[4].remote_path)
  end
end

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'test_helper'

class LocalUploaderTest < Test::Unit::TestCase
  def setup
    CdnFu::Config.clear
  end

  def teardown
    TEST_ROOT
  end

  def test_local
    config = eval(File.open(File.join(TEST_ROOT,'configs/local_upload_config.rb')).read)
    config.prepare_and_upload
  end
end

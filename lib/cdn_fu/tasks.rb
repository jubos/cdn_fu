# Load CDN Fu rakefile extensions
Dir["#{File.join(File.dirname(__FILE__),'tasks')}/*.rake"].each { |rake| 
  load rake 
}

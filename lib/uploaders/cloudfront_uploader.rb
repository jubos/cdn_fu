# This uploader using aws:s3 gem to upload everything to the specified bucket
require 'aws/s3'
class CloudfrontUploader < CdnFu::Uploader
  include AWS::S3
  required_attribute :s3_bucket
  optional_attributes :s3_access_key, :s3_secret_key

  MAX_KEYS = 1000

  def upload(file_list)
    access_key = @s3_access_key ? @s3_access_key : ENV["CDN_FU_AMAZON_ACCESS_KEY"]
    secret_key = @s3_secret_key ? @s3_secret_key : ENV["CDN_FU_AMAZON_SECRET_KEY"]

    AWS::S3::Base.establish_connection!(
      :access_key_id => access_key,
      :secret_access_key => secret_key
    )

    checksums = populate_existing_asset_checksums
    file_list.each do |file|
      upload_single_file(file)
    end
  end

  # This uploader requires a valid asset_id at the top level configuration
  # because cloudfront only invalidates its files every 24 hours, so you need
  # to have an incrementing id to avoid stale assets
  def validate
    if !CdnFuConfig.asset_id 
      raise CdnFuConfigError, "You must specify an asset_id at the top level"
    end
    access_key = @s3_access_key ? @s3_access_key : ENV["CDN_FU_AMAZON_ACCESS_KEY"]
    secret_key = @s3_secret_key ? @s3_secret_key : ENV["CDN_FU_AMAZON_SECRET_KEY"]

    if !access_key or !secret_key
      raise CdnFuConfigError, "Please specify s3_access_key and s3_secret_key attributes or use the environnment variables: CDN_FU_AMAZON_ACCESS_KEY and CDN_FU_AMAZON_SECRET_KEY"
    end
  end

  private
  def populate_existing_asset_checksums 
    @existing_asset_checksums = {}
    objects = []
    bucket = Bucket.find(@s3_bucket)
    objects += bucket.objects(:max_keys => MAX_KEYS)
    if objects.size == MAX_KEYS
      loop do
        new_objects = bucket.objects(:max_keys => MAX_KEYS,:marker => objects.last)
        objects += new_objects
        break if new_objects.size < MAX_KEYS
      end
    end
    objects.each do |obj|
      @existing_asset_checksums[obj.path] = obj.metadata['x-amz-meta-sha1-hash']
    end
    return objects
  end

  def upload_single_file(cf_file)
    versioned_filename = CdnFuConfig.asset_id + "/" + cf_file.remote_path
    options = {}
    options[:access] = :public_read
    path_to_upload = cf_file.minified_path
    path_to_upload ||= cf_file.local_path
    fstat = File.stat(path_to_upload)
    sha1sum = Digest::SHA1.hexdigest(File.open(path_to_upload).read)
    if remote_sha1 = @existing_asset_checksums["/" + s3_bucket + "/" + versioned_filename]
      if remote_sha1 != sha1sum
        puts "Your assets are different from the ones in s3 with this asset_id.  Please increment your asset_id in cdn_fu.rb"
        exit
      end
    else
      options["x-amz-meta-sha1_hash"] = sha1sum
      options["x-amz-meta-mtime"] = fstat.mtime.getutc.to_i 
      options["x-amz-meta-size"] = fstat.size
      file_content =open(path_to_upload).read 
      if cf_file.gzip? 
        options["Content-Encoding"] = 'gzip'
        strio = StringIO.open('', 'w')
        gz = Zlib::GzipWriter.new(strio)
        gz.write(file_content)
        gz.close
        file_content = strio.string
      end

      options[:cache_control] = "max-age=#{8.years.to_i}"
      options[:expires] = 8.years.from_now.httpdate
      S3Object.store(versioned_filename,file_content,s3_bucket, options)
      puts "[upload] #{s3_bucket} #{versioned_filename}"
    end
  end
end

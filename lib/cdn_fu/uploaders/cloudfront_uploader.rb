# This uploader using aws:s3 gem to upload everything to the specified bucket
require 'zlib'
require 'aws/s3'
require 'time'
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

    populate_existing_asset_checksums(file_list)

    file_list.each do |file|
      upload_single_file(file)
    end
  end

  # This uploader requires a valid asset_id at the top level configuration
  # because cloudfront only invalidates its files every 24 hours, so you need
  # to have an incrementing id to avoid stale assets
  def validate
    if !CdnFu::Config.config.asset_id 
      raise CdnFu::ConfigError, "You must specify an asset_id at the top level"
    end
    access_key = @s3_access_key ? @s3_access_key : ENV["CDN_FU_AMAZON_ACCESS_KEY"]
    secret_key = @s3_secret_key ? @s3_secret_key : ENV["CDN_FU_AMAZON_SECRET_KEY"]

    if !access_key or !secret_key
      raise CdnFu::ConfigError, "Please specify s3_access_key and s3_secret_key attributes or use the environnment variables: CDN_FU_AMAZON_ACCESS_KEY and CDN_FU_AMAZON_SECRET_KEY"
    end
  end

  private
  def populate_existing_asset_checksums(file_list)
    puts "Populating Existing Checksums...(could take a minute)" if CdnFu::Config.config.verbose
    @existing_asset_checksums = {}
    objects = []
    bucket = Bucket.find(@s3_bucket)

    file_list.each do |cf_file|
      versioned_filename = CdnFu::Config.config.asset_id.to_s + cf_file.remote_path
      begin
        obj = S3Object.about(versioned_filename,@s3_bucket)
        if obj
          existing_sha1 = obj.metadata["x-amz-meta-sha1-hash"]
          if existing_sha1
            @existing_asset_checksums[versioned_filename] = existing_sha1
          end
        end
      rescue NoSuchKey
      end
    end
  end

  def upload_single_file(cf_file)
    versioned_filename = CdnFu::Config.config.asset_id.to_s + cf_file.remote_path
    options = {}
    options[:access] = :public_read
    path_to_upload = cf_file.minified_path
    path_to_upload ||= cf_file.local_path
    fstat = File.stat(path_to_upload)
    sha1sum = Digest::SHA1.hexdigest(File.open(path_to_upload).read)
    if remote_sha1 = @existing_asset_checksums[versioned_filename]
      if remote_sha1 != sha1sum
        puts "Your assets are different from the ones in s3 with this asset_id.  Please increment your asset_id in cdn_fu.rb"
        exit
      else
        puts "Skipping #{versioned_filename}" if CdnFu::Config.config.verbose
      end
    else
      options[:access] = :public_read
      options["x-amz-meta-sha1_hash"] = sha1sum
      options["x-amz-meta-mtime"] = fstat.mtime.getutc.to_i 
      options["x-amz-meta-size"] = fstat.size
      file_content =open(path_to_upload).read 
      if cf_file.gzip? 
        puts "Gzipping"
        options["Content-Encoding"] = 'gzip'
        strio = StringIO.open('', 'w')
        gz = Zlib::GzipWriter.new(strio)
        gz.write(file_content)
        gz.close
        file_content = strio.string
      end

      eight_years = 8 * 60 * 60 * 24 * 365
      eight_years_from_now = Time.now + eight_years
      options["Cache-Control"] = "public, max-age=#{eight_years}"
      options["Expires"] = eight_years_from_now.httpdate
      S3Object.store(versioned_filename,file_content,s3_bucket, options)
      puts "[upload] #{s3_bucket} #{versioned_filename}" if CdnFu::Config.config.verbose
    end
  end
end

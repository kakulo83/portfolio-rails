class Uploader
  def initialize
    @r2 = Aws::S3::Client.new(
      access_key_id: Rails.application.credentials.cloudflare_s3_access_key,
      secret_access_key: Rails.application.credentials.cloudflare_s3_secret_key,
      endpoint: Rails.application.credentials.cloudflare_s3_endpoint,
      region: "auto"
    )
  end

  def get_r2
    @r2
  end

  def get_url(key)
    s3_resource = Aws::S3::Resource.new(client: @r2)
    bucket = s3_resource.bucket("portfolio-assets")
    bucket.presigned_post(key: key)
  end
end

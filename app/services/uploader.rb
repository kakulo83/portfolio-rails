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
    Aws::S3::PresignedPost.new(creds, "auto", "portfolio-assets", {
                                       key: key,
                                       acl: "public-read",
                                       metadata: {}
                                     }
                                    )
  end
end

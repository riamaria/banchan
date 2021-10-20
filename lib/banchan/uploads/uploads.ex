defmodule Banchan.Uploads do
  alias Banchan.Uploads.SimpleS3Upload

  def sign_s3_upload_url(bucket, path, opts \\ []) do
    config = ExAws.Config.new(:s3)

    SimpleS3Upload.sign_form_upload(
      config,
      bucket,
      [key: path] ++
        opts ++
        [
          max_file_size: 100_000_000,
          content_type: "application/octet-stream",
          expires_in: :timer.minutes(15)
        ]
    )
  end
end

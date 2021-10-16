defmodule Banchan.Uploads do
  def sign_s3_upload_url(bucket, path) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:put, bucket, path, )
  end
end

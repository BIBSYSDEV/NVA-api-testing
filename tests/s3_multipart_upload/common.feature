Feature: Common methods for multipart upload

Background:
  * def upload_endpoint = 'https://api.sandbox.nva.aws.unit.no/upload'

@create
Scenario: Create multipart upload
  * url upload_endpoint
  * path 'create'
  * request createPayload
  * method POST
  * def key = response.key
  * def uploadId = response.uploadId

@prepare
Scenario: Prepare multipart upload
  * url upload_endpoint
  * path 'prepare'
  * request preparePayload
  * method POST
  * def presignedUrl = response.url

@upload_file
Scenario: Upload file to S3
  * url uploadUrl
  * configure headers = { Accept: 'application/pdf'}
  * request filePayload
  * method put
  * def ETag = responseHeaders['ETag']
  * url upload_endpoint

@abort
Scenario: Abort multipart upload
  * url upload_endpoint
  * def abortPayload =
  """
    {
        uploadId: #(uploadId),
        key: #(key)
    }
  """
  * path 'abort'
  * request abortPayload
  * method POST

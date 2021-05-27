Feature: Common methods for mulitpart upload

Background: 
* def MULTIPART_UPLOAD_URL = 'https://api.dev.nva.aws.unit.no/upload'

@create
Scenario: Create multipart upload
  * url MULTIPART_UPLOAD_URL
  * path 'create'
  * request createPayload
  * method POST
  * def key = response.key
  * def uploadId = response.uploadId

@prepare
Scenario: Prepare multipart upload
  * url MULTIPART_UPLOAD_URL
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
  * def ETag = response.ETag
  * url #MULTIPART_UPLOAD_URL

@abort
Scenario: Abort multipart upload
  * url MULTIPART_UPLOAD_URL
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


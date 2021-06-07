Feature: API test for multipart upload to S3

Background:
  * def upload_endpoint = SERVER_URL + 'upload'
  * def headers = call read('classpath:tests/common.feature@header')
  * configure headers = headers.header
  * def uploadFile = read('classpath:test_files/multipart_upload/test_file.pdf')
  * bytes uploadFileAsBytes = read('classpath:test_files/multipart_upload/test_file.pdf')
  * def filesize = uploadFileAsBytes.length
  * def createPayload =
  """
    {
      filename: "test_file.pdf",
      size: #(filesize),
      lastmodified: 1353189358000,
      mimetype: "application/pdf"
    }
  """
  * def preparePayload =
  """
    {
      "number": 1,
      "uploadId": "uploadId",
      "body": #(uploadFile),
      "key": "key"
    }
  """
  * def completePayload =
  """
    {
      "uploadId": "uploadId",
      "parts": [
        {
          "partNumber": 1,
          "ETag": "ea1b21fd07d4e0f84b6bb94701e9c552"
        }
      ],
      "key": "key"
    }
  """

  Given url upload_endpoint

Scenario: POST create with file information returns uploadId and key and status Created
  Given path 'create'
  And request createPayload
  When method POST
  Then status 201
  And match response.uploadId == '#present'
  And match response.key == '#present'
  * call read('upload_functions.feature@abort') { uploadId: #(response.uploadId), key: #(response.key) }

Scenario: POST prepare with file payload returns url and status Ok
  * def create = call read('upload_functions.feature@create') createPayload
  * set preparePayload.uploadId = create.uploadId
  * set preparePayload.key = create.key
  Given path 'prepare'
  And request preparePayload
  When method POST
  Then status 200
  And match response.url == '#present'
  * call read('upload_functions.feature@abort') { uploadId: #(create.uploadId), key: #(create.key) }

Scenario: POST complete returns status Ok
  * def create = call read('upload_functions.feature@create') createPayload
  * set preparePayload.uploadId = create.uploadId
  * set preparePayload.key = create.key
  * def prepare = call read('upload_functions.feature@prepare') preparePayload
  * def presignedUrl = prepare.presignedUrl
  * def upload = call read('upload_functions.feature@upload_file') { uploadUrl: #(presignedUrl), filePayload: #(uploadFileAsBytes) }
  * set completePayload.uploadId = create.uploadId
  * set completePayload.key = create.key
  * set completePayload.parts[0].ETag = upload.ETag[0]
  * configure headers = bearer_token_headers
  * url upload_endpoint
  Given path 'complete'
  And request completePayload
  When method POST
  Then status 200

Scenario: POST listparts returns status Ok and a list of uploaded parts
  * def create = call read('upload_functions.feature@create') createPayload
  * set preparePayload.uploadId = create.uploadId
  * set preparePayload.key = create.key
  * def prepare = call read('upload_functions.feature@prepare') preparePayload
  * def presignedUrl = prepare.presignedUrl
  * def upload = call read('upload_functions.feature@upload_file') { uploadUrl: #(presignedUrl), filePayload: #(uploadFileAsBytes) }
  * configure headers = bearer_token_headers
  * url upload_endpoint
  * def listpartsPayload =
  """
    {
      uploadId: #(create.uploadId),
      key: #(create.key)
    }
  """
  Given path 'listparts'
  And request listpartsPayload
  When method POST
  Then status 200

Scenario: POST abort returns status Ok and message 'Multipart Upload aborted'
  * def create = call read('upload_functions.feature@create') createPayload
  * set preparePayload.uploadId = create.uploadId
  * set preparePayload.key = create.key
  * def prepare = call read('upload_functions.feature@prepare') preparePayload
  * def abortPayload =
  """
    {
      uploadId: #(create.uploadId),
      key: #(create.key)
    }
  """
  Given path 'abort'
  And request abortPayload
  When method POST
  Then status 200
  And match response.message == 'Multipart Upload aborted'

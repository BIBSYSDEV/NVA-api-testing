Feature: API test for multipart upload to S3

  Background:
    * def auth_token = 'Bearer ' + BEARER_TOKEN
    * configure headers = 
    """
    { 
        Authorization: '#(auth_token)',
        Accept: 'application/json'
    }
    """
    * def uploadFile = read('classpath:test_files/multipart_upload/test_file.json')
    * bytes uploadFileAsBytes = read('classpath:test_files/multipart_upload/test_file.json')
    * def filesize = uploadFileAsBytes.length
    * def md5hash = 
    """
        function (bytes) {
            const MessageDigest = Java.type('java.security.MessageDigest')
            const Base64 = Java.type('java.util.Base64')
            const md = MessageDigest.getInstance('MD5')
            const hash = Base64.getEncoder().encodeToString(md.digest(bytes))
            return hash
        }
    """
    * def fileMd5Hash = md5hash(uploadFileAsBytes)
    * def createPayload =
    """
        {
            filename: "test_file.json",
            size: 975944,
            lastmodified: "2010-01-01",
            mimetype: "application/json",
            md5hash: #(fileMd5Hash)
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
                    "ETag": #(fileMd5Hash)
                }
            ],
            "key": "key"
        }
    """

    Given url 'https://api.dev.nva.aws.unit.no/upload'

  Scenario: md5hash
    * print fileMd5Hash

  Scenario: POST create with file information returns uploadId and key and status Created
    Given path 'create'
    And request createPayload
    When method POST
    Then status 201
    And match response.uploadId == '#present'
    And match response.key == '#present'
    * def abortPayload =
    """
        {
            uploadId: #(response.uploadId),
            key: #(response.key)
        }
    """
    * path 'abort'
    * request abortPayload
    * method POST

  Scenario: POST prepare with file payload returns url and status Ok
    * path 'create'
    * request createPayload
    * method POST
    * def uploadId = response.uploadId
    * def key = response.key
    * copy preparePayloadCopy = preparePayload
    * set preparePayloadCopy.uploadId = uploadId
    * set preparePayloadCopy.key = key
    Given path 'prepare'
    And request preparePayloadCopy
    When method POST
    Then status 200
    And match response.url == '#present'
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

  Scenario: POST complete returns status Ok
    * path 'create'
    * request createPayload
    * method POST
    * def uploadId = response.uploadId
    * def key = response.key
    * copy preparePayloadCopy = preparePayload
    * set preparePayloadCopy.uploadId = uploadId
    * set preparePayloadCopy.key = key
    * path 'prepare'
    * request preparePayloadCopy
    * method POST
    * copy completePayloadCopy = completePayload
    * set completePayloadCopy.uploadId = uploadId
    * set completePayloadCopy.key = key
    Given path 'complete'
    And request completePayloadCopy
    When method POST
    Then status 200
  
  Scenario: POST listparts returns status Ok and a list of uploaded parts
    * path 'create'
    * request createPayload
    * method POST
    * def uploadId = response.uploadId
    * def key = response.key
    * copy preparePayloadCopy = preparePayload
    * set preparePayloadCopy.uploadId = uploadId
    * set preparePayloadCopy.key = key
    * path 'prepare'
    * request preparePayloadCopy
    * method POST
    * copy completePayloadCopy = completePayload
    * set completePayloadCopy.uploadId = uploadId
    * set completePayloadCopy.key = key
    * path 'complete'
    * request completePayloadCopy
    * method POST
    * def listpartsPayload = 
    """
        {
            uploadId: #(uploadId),
            key: #(key)
        }
    """
    Given path 'listparts'
    And request listpartsPayload
    When method POST
    Then status 200
  
  Scenario: POST abort returns status Ok and message 'Multipart Upload aborted'
    * path 'create'
    * request createPayload
    * method POST
    * def uploadId = response.uploadId
    * def key = response.key
    * copy preparePayloadCopy = preparePayload
    * set preparePayloadCopy.uploadId = uploadId
    * set preparePayloadCopy.key = key
    * path 'prepare'
    * request preparePayloadCopy
    * method POST
    * def abortPayload = 
    """
        {
            uploadId: #(uploadId),
            key: #(key)
        }
    """
    Given path 'abort'
    And request abortPayload
    When method POST
    Then status 200
    And match response.message == 'Multipart Upload aborted'

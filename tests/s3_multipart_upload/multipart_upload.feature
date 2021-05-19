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
    * def createPayload =
    """
        {
            filename: "test_file.json",
            size: #(filesize),
            lastmodified: "2010-01-01",
            mimetype: "application/json"
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
                    "partNumber": 0,
                    "ETag": ""
                }
            ],
            "key": "key"
        }
    """

    Given url 'https://api.dev.nva.aws.unit.no/upload'

  Scenario: POST create with file information returns uploadId and key and status Created
    Given path 'create'
    And request createPayload
    When method POST
    Then status 201
    And match response.uploadId == '#present'
    And match response.key == '#present'

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
    * print responseHeaders
    * copy completePayloadCopy = completePayload
    * set completePayloadCopy.uploadId = uploadId
    * set completePayloadCopy.key = key
    Given path 'complete'
    And request completePayloadCopy
    When method POST
    Then status 200
  
    

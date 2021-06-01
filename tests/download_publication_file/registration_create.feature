Feature: Create registration with uploaded file

  Background:
    * def upload_endpoint = 'https://api.sandbox.nva.aws.unit.no/upload'
    * def create_registration_endpoint = 'https://api.sandbox.nva.aws.unit.no/publication'
    * def resourcePayload = read('classpath:test_files/download_publication_file/correct_resource_payload.json')
    * def uploadFile = read('classpath:test_files/download_publication_file/test_file.pdf')
    * bytes uploadFileAsBytes = read('classpath:test_files/download_publication_file/test_file.pdf')
    * def filesize = uploadFileAsBytes.length
    * configure headers = 
    """
      { 
        Authorization: '#(auth_token)',
        Accept: 'application/json'
      }
    """
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
                    "ETag": "####################"
                }
            ],
            "key": "key"
        }
    """
  @upload_file
  Scenario: Upload file
  * url upload_endpoint
  # create upload
  * path 'create'
  * request createPayload
  * method POST
  * def key = response.key
  * def uploadId = response.uploadId
  # prepare upload
  * path 'prepare'
  * set preparePayload.key = key
  * set preparePayload.uploadId = uploadId
  * request preparePayload
  * method POST
  * def presignedUrl = response.url
  # upload file
  * url presignedUrl
  * configure headers =
  """
      Accept: 'application/pdf'
  """
  * request uploadFileAsBytes
  * method PUT
  * def ETag = responseHeaders['ETag']
  # complete upload
  * url upload_endpoint
  * configure headers = 
  """
    { 
        Authorization: '#(auth_token)',
        Accept: 'application/pdf'
    }
  """  
  * set completePayload.uploadId = uploadId
  * set completePayload.key = key
  * set completePayload.parts[0].ETag = ETag[0]
  * path 'complete'
  * request completePayload
  * method POST
  * def location = response['location']

  @create_registration
  Scenario: Create registration
    # add file identifier to registration
    * set resourcePayload['fileSet']['files'][0].identifier = file_identifier
    * set resourcePayload['fileSet']['files'][0].size = filesize
    # create registration
    * url create_registration_endpoint
    * path '/'
    * request resourcePayload
    * method POST
    # publish registration
    * def identifier = response.identifier
    * path (`${identifier}/publish`)
    * method PUT

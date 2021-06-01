Feature: Create registration with uploaded file

  Background:
    * def resourcePayload = read('classpath:test_files/download_publication_file/correct_resource_payload.json')
    * def upload_endpoint = 'https://api.sandbox.nva.aws.unit.no/upload'
    * print upload_endpoint
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
  # create
  * path 'create'
  * request createPayload
  * method POST
  * def key = response.key
  * def uploadId = response.uploadId
  # prepare
  * path 'prepare'
  * set preparePayload.key = key
  * set preparePayload.uploadId = uploadId
  * request preparePayload
  * method POST
  * def presignedUrl = response.presignedUrl
  # upload
  * url presignedUrl
  * configure headers =
  """
      Accept: 'application/pdf'
  """
  * request filePayload
  * method PUT
  * def ETag = responseHeaders['ETag']
  # complete
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
  * set resourcePayload['fileSet']['files'][0]['identifer'] = file_identifier 
  * print resourcePayload
  # create registration
    # * path '/'
    # * request resourcePayload
    # * method POST
  * def identifier = response.identifer
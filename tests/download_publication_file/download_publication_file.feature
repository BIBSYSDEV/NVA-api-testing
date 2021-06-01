Feature: Test for download publication file API

  Background:
    * def auth_token = 'Bearer ' + BEARER_TOKEN
    * configure headers = 
    """
      { 
        Authorization: '#(auth_token)',
        Accept: 'application/json'
      }
    """
    * def file_create_result = callonce read('registration_create.feature@upload_file')
    * def registration_create_result = callonce read('registration_create.feature@create_registration') { file_identifier: #(file_create_result.location)} 
    * print registration_create_result.identifier

    Given url 'https://api.sandbox.nva.aws.unit.no/download'

  Scenario: GET /public with identifier and fileIdentifier returns status OK and presignedDownloadUrl
    Given path '/public/69689c32-de34-4338-9084-6fb137f0b1dc/files/1ff380ae-2362-46c6-be63-e92c1a1debbf'
    When method GET
    Then status 200
    And match response.presignedDonwloadUrl == '#present'

  Scenario: GET with identifier and fileIdentifier returns status OK and presignedDownloadUrl
    Given path '/69689c32-de34-4338-9084-6fb137f0b1dc/files/1ff380ae-2362-46c6-be63-e92c1a1debbf'
    When method GET
    Then status 200
    And match response.presignedDonwloadUrl == '#present'

  Scenario: search for file
    * url 'https://api.sandbox.nva.aws.unit.no/search'
    Given path '/resources'
    And param query = 'APItestdownloadpublicationfile'
    When method GET
    Then status 200
    * def identifier = response.hits[0]['id']
    # * def identifier = 'd1095b17-927c-4260-8822-3913b568b4f2'
    * print identifier
    * url 'https://api.sandbox.nva.aws.unit.no/publication'
    * path identifier
    * method GET


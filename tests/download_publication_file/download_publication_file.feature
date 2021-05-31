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


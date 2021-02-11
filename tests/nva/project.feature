Feature: Project API testing

  Background:
    * def host = ''
    * def basePath = 'https://' + host + '/project/
    * def projectIdRegex = 'https:\/\/[^\/]+\/project\/[0-9]+'
    * def searchPath = basePath + 'search?q=*'
    * def apiKey = karate.properties['PROJECT_API_KEY']
    * def getResponse = read('../../test_files/nva/project_search_get_result.json')


  Scenario: Query with content negotiation JSON-LD returns expected response
    * configure headers = { 'Content-type': 'application/ld+json', 'Authorization: Basic ' + apiKey }
    Given url searchPath
    When method get
    Then status 200
    And match response == '#object'
    And response['@context'] == '#present'
    And response.id == searchPath
    And response.total == '#present'
    And response.hits == '#present'
    And response.hits[0].type == '#present'
    And response.hits[0].id == '#regex ' + projectIdRegex

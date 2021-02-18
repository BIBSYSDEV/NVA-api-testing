Feature: Project API testing

  Background:
    * def host = ''
    * def basePath = 'https://' + host + '/project/
    * def projectIdRegex = 'https:\/\/[^\/]+\/project\/[0-9]+'
    * def searchPath = basePath + 'search?q='
    * def token = karate.properties['PROJECT_API_KEY']
    * def currentEnvironment = karate.properties['CURRENT_ENVIRONMENT']
    * def searchResponse = read('../../test_files/nva/project_search_get_result.json').replace('__CURRENT_ENVIRONMENT__', currentEnvironment)
    * def projectResponse = read('../../test_files/nva/project_get_result.json')
    * def nonExistingProject = 'not-a-real-project'
    * def unauthenticatedProblem = read('../../test_files/nva/unauthenticated_problem.json').replace('__RESOURCE_URI__', nonExistingProject)

  Scenario: Query and receive CORS preflight response
    * configure headers = {'Origin': 'http://localhost:3000', 'Accept': '*/*', 'Referer': 'Not sure what the value should be yet', 'Origin': 'https://' + currentEnvironment + '/registration/aUuid', 'Connection', 'keep-alive', 'Accept-Encoding: gzip, deflate, br', 'Access-Control-Request-Method': 'GET', Access-Control-Request-Headers: authorization}
    Given url searchPath + 'test'
    When method OPTIONS
    Then status 200
    And match responseHeaders['Content-Type'] == 'application/json'
    And match responseHeaders['Access-Control-Allow-Origin'] == '*'
    And match responseHeaders['Access-Control-Allow-Methods'] == 'GET,OPTIONS'
    And match responseHeaders['Access-Control-Allow-Headers'] == 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
    And match responseHeaders['Vary'] == 'Origin'

  Scenario Outline: Unauthenticated search request is rejected
    * configure headers = { 'Content-type': <Content-type> }
    Given path <URL>
    When method get
    Then status 401
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == unauthenticatedProblem

    Examples:
      | URL                       | Content-type          |
      | searchPath + 'irrelevant' | 'application/ld+json' |
      | existingProject           | 'application/json'    |

  Scenario Outline: GET non-existing resource
    * configure headers = { 'Content-type': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    When method get
    Then status 404
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Not found", "status": 404, "detail": "The requested resource "' + basePath + nonExistingProject + " does not exist"'}

    Examples:
      | URL                           | Content-type          |
      | basePath + nonExistingProject | 'application/ld+json' |
      | basePath + nonExistingProject | 'application/json'    |
      | basePath + 'anythingElse'     | 'application/ld+json' |
      | basePath + 'anythingElse'     | 'application/json'    |

  Scenario Outline: Query proxy error gives Bad Gateway problem response
    * configure headers = { 'Content-type': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    And the Cristin API is down
    When method get
    Then status 502
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Bad Gateway", "status": 502, "detail": "Your request cannot be processed at this time due to an upstream error'}

    Examples:
      | URL                       | Content-type          |
      | searchPath + 'pancreatic' | 'application/ld+json' |
      | searchPath + 'pancreatic' | 'application/json'    |
      | existingResource          | 'application/ld+json' |
      | existingResource          | 'application/json'    |

  Scenario Outline: Slow upstream gives Gateway Timeout problem response
    * configure headers = { 'Content-type': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    And the Cristin API response takes longer than 2 seconds
    When method get
    Then status 504
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Gateway Timeout", "status": 504, "detail": "Your request cannot be processed at this time because the upstream server response took too long'}

    Examples:
      | URL                       | Content-type          |
      | searchPath + 'pancreatic' | 'application/ld+json' |
      | searchPath + 'pancreatic' | 'application/json'    |
      | existingResource          | 'application/ld+json' |
      | existingResource          | 'application/json'    |

  Scenario Outline: Unexpected error returns Internal Server Error problem response
    * configure headers = { 'Content-type': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    And the Cristin API response takes longer than 2 seconds
    When method get
    Then status 500
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Gateway Timeout", "status": 500, "detail": "Your request cannot be processed at this time because of an internal server error'}

    Examples:
      | URL                       | Content-type          |
      | searchPath + 'pancreatic' | 'application/ld+json' |
      | searchPath + 'pancreatic' | 'application/json'    |
      | existingResource          | 'application/ld+json' |
      | existingResource          | 'application/json'    |

  Scenario Outline: Query with method non-GET gives Method error
    * configure headers = { 'Content-type': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given path existingProject
    And the Cristin API response takes longer than 2 seconds
    When method <METHOD>
    Then status 504
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Gateway Timeout", "status": 504, "detail": "Your request cannot be processed at this time because the upstream server response took too long'}

    Examples:
      | METHOD  | Content-type          |
      | DELETE  | 'application/ld+json' |
      | DELETE  | 'application/json'    |
      | PATCH   | 'application/ld+json' |
      | PATCH   | 'application/json'    |
      | POST    | 'application/ld+json' |
      | POST    | 'application/json'    |
      | PUT     | 'application/ld+json' |
      | PUT     | 'application/json'    |
      | CONNECT | 'application/ld+json' |
      | CONNECT | 'application/json'    |
      | TRACE   | 'application/ld+json' |
      | TRACE   | 'application/json'    |

  Scenario Outline: Query with bad parameters returns Bad Request
    * configure headers = { 'Accept': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    When method get
    Then status 400
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Bad Request", "status": 400, "detail": "Your request cannot be processed because the supplied parameter(s) "not" cannot be understood'}

    Examples:
      | URL                         | Content-type          |
      | basePath + 'search?not=pog' | 'application/ld+json' |
      | basePath + 'search?not=pog' | 'application/json'    |

  Scenario Outline: Request with bad content type returns Not Acceptable
    * configure headers = { 'Accept': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    When method get
    Then status 406
    And match responseHeaders['Content-type'] == 'application/problem+json'
    And match response == '{"title": "Not Acceptable", "status": 406, "detail": "Your request cannot be processed because the supplied content-type <Content-type> cannot be understood'}

    Examples:
      | URL                       | Content-type             |
      | searchPath + 'pancreatic' | 'image/jpeg'             |
      | searchPath + 'pancreatic' | 'application/xml'        |
      | searchPath + 'pancreatic' | 'application/rdf+xml'    |
      | existingResource          | 'image/jpeg'             |
      | existingResource          | 'application/xml'        |
      | existingResource          | 'application/rdf+xml'    |


  Scenario Outline: Search with content negotiation returns expected response
    * configure headers = { 'Accept': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url searchPath + 'pancreatic'
    When method get
    Then status 200
    And contentType = <Content-type>
    And match response == searchResponse.replace('__PROCESSING_TIME__', response.processingTime)

    Examples:
      | Content-type          |
      | 'application/ld+json' |
      | 'application/json'    |

  Scenario Outline: Search returns no more than ten results
    * configure headers = { 'Accept': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url searchPath + 'and'
    When method get
    Then status 200
    And contentType = <Content-type>
    And match response.hits.length < 11

    Examples:
      | Content-type          |
      | 'application/ld+json' |
      | 'application/json'    |


  Scenario Outline: Search returns next ten results
    * configure headers = { 'Accept': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url searchPath + 'and&start=11'
    When method get
    Then status 200
    And contentType = <Content-type>
    And match response.hits.length < 11
    And match response.firstRecord == 11

    Examples:
      | Content-type          |
      | 'application/ld+json' |
      | 'application/json'    |

  Scenario Outline: Request with content negotiation returns expected response
    * configure headers = { 'Accept': <Content-type>, 'Authorization: Basic ' + token }
    * contentType = responseHeaders['Content-Type'][0]
    Given url <URL>
    When method get
    Then status 200
    And contentType = <Content-type>
    And match response == projectResponse

    Examples:
      | URL                       | Content-type          |
      | existingResource          | 'application/ld+json' |
      | existingResource          | 'application/json'    |


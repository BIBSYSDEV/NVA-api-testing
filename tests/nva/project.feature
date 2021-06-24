Feature: Project API testing

Background:
  * def host = 'https://api.dev.nva.aws.unit.no'
  * def basePath = host + '/project/'
  * def projectIdRegex = 'https:\/\/[^\/]+\/project\/[0-9]+'
  * def searchPath = basePath + '?query='
  * def currentEnvironment = CURRENT_ENVIRONMENT
  * def searchResponse = read('classpath:test_files/nva/project_search_get_result.json')
  * def projectResponse = read('classpath:test_files/nva/project_get_result.json')
  * def nonExistingProject = 'not-a-real-project'
  * def PROBLEM_JSON_MEDIA_TYPE = 'application/problem+json'
  * def JSON_LD_MEDIA_TYPE = 'application/ld+json'
  * def JSON_MEDIA_TYPE = 'application/json'
  * def existingProject = 'https://api.dev.nva.aws.unit.no/project/2057367'
  * def existingResource = 'https://api.dev.nva.aws.unit.no/project/2057367'

Scenario: Query and receive CORS preflight response
  * configure headers =
  """
    {
      'Origin': 'http://localhost:3000',
      'Accept': '*/*',
      'Referer': 'Not sure what the value should be yet',
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip, deflate, br',
      'Access-Control-Request-Method': 'GET'
    }
  """
  * print searchPath
  Given url searchPath + 'test'
  When method OPTIONS
  Then status 200
  And match responseHeaders['Access-Control-Allow-Origin'][0] == '*'
  * def accessControlAllowMethods = responseHeaders['Access-Control-Allow-Methods'][0]
  And match accessControlAllowMethods contains 'GET'
  And match accessControlAllowMethods contains 'OPTIONS'
  * def accessControlAllowHeaders = responseHeaders['Access-Control-Allow-Headers'][0]
  And match accessControlAllowHeaders contains 'Content-Type'
  And match accessControlAllowHeaders contains 'X-Amz-Date'
  And match accessControlAllowHeaders contains 'Authorization'
  And match accessControlAllowHeaders contains 'X-Api-Key'
  And match accessControlAllowHeaders contains 'X-Amz-Security-Token'
  And match accessControlAllowHeaders contains 'Access-Control-Allow-Origin'


Scenario Outline: Query proxy error gives Bad Gateway problem response
  * configure headers = { 'Content-type': <CONTENT_TYPE> }
  Given url <VALID_URL>
  # And the Cristin API is down
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 502
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title 'Bad Gateway'
  And match response.status == 502
  And match response.detail == 'Your request cannot be processed at this time due to an upstream error'
  And match response.instance == <VALID_URL>
  And match response.requestId == '#notnull'

Examples:
  | VALID_URL                 | CONTENT_TYPE       |
  | searchPath + 'pancreatic' | JSON_LD_MEDIA_TYPE |
  | searchPath + 'pancreatic' | JSON_MEDIA_TYPE    |
  | existingResource          | JSON_LD_MEDIA_TYPE |
  | existingResource          | JSON_MEDIA_TYPE    |

Scenario Outline: Slow upstream gives Gateway Timeout problem response
  * configure headers = { 'Content-type': <CONTENT_TYPE> }
  Given url <VALID_URL>
  # And the Cristin API response takes longer than 2 seconds
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 504
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Gateway Timeout'
  And match response.status == 504
  And match response.detail == 'Your request cannot be processed at this time because the upstream server response took too long'
  And match response.instance == <VALID_URL>
  And match response.requestId == '#notnull'

Examples:
  | VALID_URL                 | CONTENT_TYPE       |
  | searchPath + 'pancreatic' | JSON_LD_MEDIA_TYPE |
  | searchPath + 'pancreatic' | JSON_MEDIA_TYPE    |
  | existingResource          | JSON_LD_MEDIA_TYPE |
  | existingResource          | JSON_MEDIA_TYPE    |

Scenario Outline: Unexpected error returns Internal Server Error problem response
  * configure headers = { 'Content-type': <CONTENT_TYPE> }
  Given url <VALID_URL>
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  # And the project API application experiences an unexpected error
  Then status 500
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Internal Server Error'
  And match response.status == 500
  And match response.detail == 'Your request cannot be processed at this time because of an internal server error'
  And match response.instance == <VALID_URL>
  And match response.requestId == '#notnull'

Examples:
  | VALID_URL                 | CONTENT_TYPE        |
  | searchPath + 'pancreatic' | JSON_LD_MEDIA_TYPE' |
  | searchPath + 'pancreatic' | JSON_MEDIA_TYPE     |
  | existingResource          | JSON_LD_MEDIA_TYPE  |
  | existingResource          | JSON_MEDIA_TYPE     |

Scenario Outline: Query with unacceptable method returns Not acceptable error
  * configure headers = { 'Content-type': <CONTENT_TYPE>, Authentication: 'Bearer Whatever' }
  * print 'existingProject'
  * print existingProject
  Given url existingProject
  When method <METHOD>
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 406
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Not acceptable'
  And match response.status == 406
  And match response.detail == 'Your request cannot be processed because the HTTP method ' + <METHOD> + ' is not supported'
  #And match response.instance == existingProject
  And match response.requestId == '#notnull'

Examples:
  | METHOD  | CONTENT_TYPE       |
  | DELETE  | JSON_LD_MEDIA_TYPE |
  | DELETE  | JSON_MEDIA_TYPE    |
  | PATCH   | JSON_LD_MEDIA_TYPE |
  | PATCH   | JSON_MEDIA_TYPE    |
  | POST    | JSON_LD_MEDIA_TYPE |
  | POST    | JSON_MEDIA_TYPE    |
  | PUT     | JSON_LD_MEDIA_TYPE |
  | PUT     | JSON_MEDIA_TYPE    |
  | CONNECT | JSON_LD_MEDIA_TYPE |
  | CONNECT | JSON_MEDIA_TYPE    |
  | TRACE   | JSON_LD_MEDIA_TYPE |
  | TRACE   | JSON_MEDIA_TYPE    |

Scenario Outline: Query with bad parameters returns Bad Request
  * configure headers = { 'Accept': <CONTENT_TYPE> }
  Given url <BAD_REQUEST_PARAMETER_URL>
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 400
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Bad Request'
  And match response.status == 400
  And match response.detail == "Invalid query param supplied. Valid ones are 'query', 'page', 'results' and 'language'"
  #And match response.instance == <BAD_REQUEST_PARAMETER_URL>
  And match response.requestId == '#notnull'

Examples:
  | BAD_REQUEST_PARAMETER_URL | CONTENT_TYPE          |
  | basePath + '?not=pog'     | 'application/ld+json' |
  | basePath + '?not=pog'     | 'application/json'    |

Scenario Outline: Request with bad content type returns Not Acceptable
  * configure headers = { 'Accept': <UNACCEPTABLE_CONTENT_TYPE> }
  Given url <VALID_URL>
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 406
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Not Acceptable'
  And match response.status == 406
  And match response.detail == "Your request cannot be processed because the supplied content-type '" + <UNACCEPTABLE_CONTENT_TYPE> + "' cannot be understood"
  #And match response.instance == <VALID_URL>
  And match response.requestId == '#notnull'

Examples:
  | VALID_URL                 | UNACCEPTABLE_CONTENT_TYPE |
  | searchPath + 'pancreatic' | 'image/jpeg'              |
  | searchPath + 'pancreatic' | 'application/xml'         |
  | searchPath + 'pancreatic' | 'application/rdf+xml'     |
  | existingResource          | 'image/jpeg'              |
  | existingResource          | 'application/xml'         |
  | existingResource          | 'application/rdf+xml'     |

Scenario Outline: Search with content negotiation returns expected response
  * configure headers = { 'Accept': <CONTENT_TYPE> }
  Given url searchPath + 'pancreatic'
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And match response == searchResponse.replace('__PROCESSING_TIME__', response.processingTime)

Examples:
  | CONTENT_TYPE          |
  | 'application/ld+json' |
  | 'application/json'    |

Scenario Outline: Search returns no more than five results
  * configure headers = { 'Accept': <CONTENT_TYPE> }
  Given url searchPath + 'and'
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And assert response.hits.length < 6

Examples:
  | CONTENT_TYPE          |
  | 'application/ld+json' |
  | 'application/json'    |

Scenario Outline: Search returns next five results
  * configure headers = { 'Accept': <CONTENT_TYPE> }
  Given url searchPath + 'and&page=2'
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And assert response.hits.length < 6
  And match response.firstRecord == 6

Examples:
  | CONTENT_TYPE          |
  | 'application/ld+json' |
  | 'application/json'    |

Scenario Outline: Request with content negotiation returns expected response
  * configure headers = { 'Accept': <CONTENT_TYPE> }
  Given url existingResource
  When method get
  * def contentType = responseHeaders['Content-Type'][0]
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And match response != null

Examples:
  | CONTENT_TYPE          |
  | 'application/ld+json' |
  | 'application/json'    |

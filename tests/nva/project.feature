Feature: Project API testing

Background:
  * def host = ''
  * def basePath = 'https://' + host + '/project/
  * def projectIdRegex = 'https:\/\/[^\/]+\/project\/[0-9]+'
  * def searchPath = basePath + 'search?q='
  * def token = karate.properties['PROJECT_API_KEY']
  * def currentEnvironment = karate.properties['CURRENT_ENVIRONMENT']
  * def searchResponse = read('classpath:test_files/nva/project_search_get_result.json').replace('__CURRENT_ENVIRONMENT__', currentEnvironment)
  * def projectResponse = read('classpath:test_files/nva/project_get_result.json')
  * def nonExistingProject = 'not-a-real-project'
  * def PROBLEM_JSON_MEDIA_TYPE = 'application/problem+json'
  * def JSON_LD_MEDIA_TYPE = 'application/ld+json'
  * def JSON_MEDIA_TYPE = 'application/json'

Scenario: Query and receive CORS preflight response
  * configure headers = {'Origin': 'http://localhost:3000', 'Accept': '*/*', 'Referer': 'Not sure what the value should be yet', 'Origin': 'https://' + currentEnvironment + '/registration/aUuid', 'Connection', 'keep-alive', 'Accept-Encoding: gzip, deflate, br', 'Access-Control-Request-Method': 'GET', Access-Control-Request-Headers: authorization}
  * contentType = responseHeaders['Content-Type'][0]
  Given url searchPath + 'test'
  When method OPTIONS
  Then status 200
  And match contentType == JSON_MEDIA_TYPE
  And match responseHeaders['Access-Control-Allow-Origin'][0] == '*'
  And match responseHeaders['Access-Control-Allow-Methods'][0] == 'GET,OPTIONS'
  And match responseHeaders['Access-Control-Allow-Headers'][0] == 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
  And match responseHeaders['Vary'][0] == 'Origin'

Scenario Outline: Unauthenticated search request is rejected
  * configure headers = { 'Content-type': <CONTENT_TYPE> }
  * contentType = responseHeaders['Content-Type'][0]
  Given path <VALID_URL>
  When method get
  Then status 401
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Unauthorized'
  And match response.status == 401
  And match response.detail == 'You are not authorized to access the resource ' + <VALID_URL>
  And match response.instance == <VALID_URL>
  And match response.requestId == '#notnull'

Examples:
  | VALID_URL                 | CONTENT_TYPE       |
  | searchPath + 'irrelevant' | JSON_LD_MEDIA_TYPE |
  | existingProject           | JSON_MEDIA_TYPE    |

Scenario Outline: Requesting non-existing resource returns not found error
  * configure headers = { 'Content-type': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url <NON_EXISTING_RESOURCE_URL>
  When method get
  Then status 404
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Not found'
  And match response.status == 404
  And match response.detail == 'The requested resource ' + basePath + nonExistingProject + ' does not exist'
  And match response.instance == <NON_EXISTING_RESOURCE_URL>
  And match response.requestId == '#notnull'

Examples:
  | NON_EXISTING_RESOURCE_URL     | CONTENT_TYPE       |
  | basePath + nonExistingProject | JSON_LD_MEDIA_TYPE |
  | basePath + nonExistingProject | JSON_MEDIA_TYPE    |
  | basePath + 'anythingElse'     | JSON_LD_MEDIA_TYPE |
  | basePath + 'anythingElse'     | JSON_MEDIA_TYPE    |

Scenario Outline: Query proxy error gives Bad Gateway problem response
  * configure headers = { 'Content-type': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url <VALID_URL>
  And the Cristin API is down
  When method get
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
  * configure headers = { 'Content-type': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url <VALID_URL>
  And the Cristin API response takes longer than 2 seconds
  When method get
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
  * configure headers = { 'Content-type': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url <VALID_URL>
  When method get
  And the project API application experiences an unexpected error
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
  * configure headers = { 'Content-type': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given path existingProject
  When method <METHOD>
  Then status 506
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Not acceptable'
  And match response.status == 506
  And match response.detail == 'Your request cannot be processed because the HTTP method ' + <METHOD> + ' is not supported'
  And match response.instance == existingProject
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
  * configure headers = { 'Accept': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url <BAD_REQUEST_PARAMETER_URL>
  When method get
  Then status 400
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Bad Request'
  And match response.status == 400
  And match response.detail == 'Your request cannot be processed because the supplied parameter(s) "not" cannot be understood'
  And match response.instance == <BAD_REQUEST_PARAMETER_URL>
  And match response.requestId == '#notnull'

Examples:
  | BAD_REQUEST_PARAMETER_URL   | CONTENT_TYPE       |
  | basePath + 'search?not=pog' | JSON_LD_MEDIA_TYPE |
  | basePath + 'search?not=pog' | JSON_MEDIA_TYPE    |

Scenario Outline: Request with bad content type returns Not Acceptable
  * configure headers = { 'Accept': <UNACCEPTABLE_CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url <VALID_URL>
  When method get
  Then status 406
  And match contentType == PROBLEM_JSON_MEDIA_TYPE
  And match response.title == 'Not Acceptable'
  And match response.status == 406
  And match response.detail == 'Your request cannot be processed because the supplied content-type ' + <UNACCEPTABLE_CONTENT_TYPE> + ' cannot be understood'
  And match response.instance == <VALID_URL>
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
  * configure headers = { 'Accept': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url searchPath + 'pancreatic'
  When method get
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And match response == searchResponse.replace('__PROCESSING_TIME__', response.processingTime)

Examples:
  | CONTENT_TYPE       |
  | JSON_LD_MEDIA_TYPE |
  | JSON_MEDIA_TYPE    |

Scenario Outline: Search returns no more than ten results
  * configure headers = { 'Accept': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url searchPath + 'and'
  When method get
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And match response.hits.length < 11

Examples:
  | CONTENT_TYPE       |
  | JSON_LD_MEDIA_TYPE |
  | JSON_MEDIA_TYPE    |

Scenario Outline: Search returns next ten results
  * configure headers = { 'Accept': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url searchPath + 'and&start=11'
  When method get
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And match response.hits.length < 11
  And match response.firstRecord == 11

Examples:
  | CONTENT_TYPE       |
  | JSON_LD_MEDIA_TYPE |
  | JSON_MEDIA_TYPE    |

Scenario Outline: Request with content negotiation returns expected response
  * configure headers = { 'Accept': <CONTENT_TYPE>, 'Authorization: Basic ' + token }
  * contentType = responseHeaders['Content-Type'][0]
  Given url existingResource
  When method get
  Then status 200
  And match contentType == <CONTENT_TYPE>
  And match response == projectResponse

Examples:
  | CONTENT_TYPE       |
  | JSON_LD_MEDIA_TYPE |
  | JSON_MEDIA_TYPE    |

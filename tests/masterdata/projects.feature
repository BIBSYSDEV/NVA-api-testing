Feature: Project API testing

  Background:
    * def path = 'pg58r9n6ff.execute-api.eu-west-1.amazonaws.com'
    * def existingProject = '435486'
    * def payload = read('../../test_files/masterdata/project_post_body.json')
    * def getResponse = read('../../test_files/masterdata/project_get_result.json')
    * set getResponse.id = 'https://' + path + '/v1/projects/435486'
    * def postResponse = read('../../test_files/masterdata/project_post_result.json')
    * copy patchPayload = payload


    Given url 'https://' + path + '/v1/projects'

    * configure headers = 
      """
      { 
        'Content-type': 'application/json', 
        'x-client-id': 'nvatest', 
        'x-client-token': 'zl5yxb-cke502-164uqh-84n023m' 
      }
      """

  Scenario: GET project success
    Given path existingProject
    When method get
    Then status 200
    And match response == getResponse

  Scenario: GET project wrong id
    Given path '1234567890'
    When method get
    Then status 400
    And match response.trace == '#uuid'
    And match response.messages == '#present'
    And match response.status == 400
  
  Scenario: GET project not authenticated
    * configure headers = { 'Content-type': 'application/json' }
    Given path existingProject
    When method get
    Then status 401
    And response.trace == '#uuid'

  Scenario: POST new project
    Given path '/'
    And request payload
    When method post
    Then status 201
    And match response == postResponse

  Scenario: POST project not authenticated
    * configure headers = { 'Content-type': 'application/json' }
    Given path '/'
    And request payload
    When method post
    Then status 401
    And response.trace == '#uuid'

  Scenario: POST project missing field
    * copy invalidPayload = payload
    * remove invalidPayload.title
    Given path '/'
    And request invalidPayload
    When method post
    Then status 502

  Scenario: PATCH project
    Given path '/'
    And request payload
    When method post
    * karate.set('id', response.id.split('/').pop())
    Given path '/' + id
    When method get
    Then status 200
    
    * def changedTitle = 
    """
      {
        "no": "Testprosjekt NVA - endret",
        "en": "Testproject NVA - changed"
      }
    """
    * set patchPayload.title = changedTitle
    Given path '/' + id
    And request patchPayload
    When method patch
    Then status 204

    Given path '/' + id
    When method get
    Then status 200
    And match response.title == changedTitle

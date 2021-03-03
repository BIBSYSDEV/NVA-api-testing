Feature: Tests for NVA customers API

  Background:
    Given url 'https://api.dev.nva.aws.unit.no/customer'
    * def auth_token = 'Bearer ' + BEARER_TOKEN
    * configure headers = 
    """
      { 
        Authorization: '#(auth_token)',
        Accept: 'application/json'
      }
    """
    * def postSuccessPayload = read('../../test_files/nva_customers/post_success_payload.json')
    * karate.log(postSuccessPayload)

  Scenario: GET returns status Ok and array of all customers
    Given path '/'
    When method GET
    Then status 200
    And match response.customers == '#present'
    And match response.customers == '#array'

  Scenario: POST returns status Created and Customer details
    Given path '/'
    * configure headers = 
    """
      { 
        Authorization: '#(auth_token)',
        Accept: 'application/json',
        'Content-Type': 'application/json',
      }
    """
    And request postSuccessPayload
    When method POST
    Then status 201
    And match header Content-Type == 'application/json'
    And match response.identifier == '#uuid'
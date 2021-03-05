Feature: Registration API tests

    Background: 
      * def auth_token = 'Bearer ' + BEARER_TOKEN
      * configure headers = 
      """
        { 
          Authorization: '#(auth_token)',
          Accept: 'application/json'
        }
      """
      
      Given url 'https://api.dev.nva.aws.unit.no/users-roles-internal/publication'

    Scenario: GET '/' with pagesize set returns list of Registrations up to pagesize and status Ok when requesting existing Registration
        Given path '/'
        And param pagesize = 100
        When method GET
        Then status 200


    Scenario: GET returns Registration and status Ok when requesting existing Registration

    Scenario: GET returns status Not Found when requesting non-existing Registration

    Scenario: 
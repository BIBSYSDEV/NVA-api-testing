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

      Given url 'https://api.dev.nva.aws.unit.no/temp-publication'

    Scenario: GET '/' with pagesize set returns list of Registrations up to pagesize and status Ok when requesting existing Registration
      * configure headers =
      """
        {
          Accept: 'application/json'
        }
      """
      Given path '/'
      And param pagesize = '100'
      When method GET
      Then status 200


    Scenario: GET returns Registration and status Ok when requesting existing Registration
      * path '/'
      * param pagesize = '10'
      * method GET
      * def identifier = response[0]['identifier'] 
      Given path '/' + identifier
      When method GET
      Then status 200

    Scenario: GET returns status Not Found when requesting non-existing Registration

    Scenario: 
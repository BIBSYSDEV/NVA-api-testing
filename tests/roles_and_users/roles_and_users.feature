Feature: Roles and users API tests

    Background: 
      * def auth_token = 'Bearer ' + BEARER_TOKEN
      * configure headers = 
      """
        { 
          Authorization: '#(auth_token)',
          Accept: 'application/json'
        }
      """

      Given url 'https://api.dev.nva.aws.unit.no/users-roles'

    Scenario: 
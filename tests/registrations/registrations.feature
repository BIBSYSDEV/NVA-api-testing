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
      * def correctMessage = 
      """
      {
        "messageType": "DoiRequest",
        "publicationIdentifier": "2881840c-b101-4871-920f-d40010689e5a",
        "message": "Test message"
      }
      """

      Given url 'https://api.dev.nva.aws.unit.no/publication'

    Scenario: GET returns Registration and status Ok when requesting existing Registration
      * path '/by-owner'
      * method GET
      * def identifier = response[0]['identifier']
      Given path '/' + identifier
      When method GET
      Then status 200

    Scenario: (Post resource)

    Scenario: (Put resource)

    Scenario: (Delete resource)

    Scenario: (Put publish resource)

    Scenario: GET returns status Not Found when requesting non-existing Registration

    Scenario: (Get by-owner)

    Scenario: (Get doirequest by role)

    Scenario: (Post update doirequest)

    Scenario Outline: GET messages by role returns status Ok
    Given path '/messages'
    And param role = '<Role>'
    When method GET
    Then status 200
    Examples:
    | Role    |
    | Creator |
    | Curator |

    Scenario: POST message returns status Created
      Given path '/messages'
      And request correctMessage
      When method POST
      Then status 201

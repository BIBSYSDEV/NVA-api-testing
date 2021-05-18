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
      * def randomIdentifier = 
      """
        function() {
          return '' + Number(new Date().getTime()).toString(16) + '-' + java.util.UUID.randomUUID();
        }
      """
      * def correctMessage = read('classpath:test_files/nva_registrations/correct_message_payload.json')
      * def correctDoirequestPayload = read('classpath:test_files/nva_registrations/correct_doirequest_payload.json')
      * def correctResourcePayload = read('classpath:test_files/nva_registrations/correct_resource_payload.json')
      * def correctResourceUpdatePayload = read('classpath:test_files/nva_registrations/update_resource_payload.json')
      * def updateStatusPayload = read('classpath:test_files/nva_registrations/update_resource_status_payload.json')
      * def nonExistingResourceId = randomIdentifier()
      * def invalidIdentifier = 'invalid-identifier'
      * def mainTitleGet = 'API test registration GET'
      * def mainTitleUpdate = 'API test registration PUT'
      * def updatedMainTitle = 'API test registration PUT updated'
      * def mainTitleDelete = 'API test registration DELETE'
      * def mainTitlePublish = 'API test registration PUT publish'
      * def mainTitleDoiRequestCreate = 'API test registration DoiRequest'
      * def mainTitleMessageCreate = 'API test registration Message'

      * def findIdentifier = 
      """
        function(registrationList, title) {
          if (!title) {
            return registrationList[0].identifier;
          }
          var registrationId = 'not found'
          registrationList.forEach(function(registration) {
            if(registration['mainTitle'] === title) {
              registrationId = registration['identifier'];
            }
          });
          return registrationId
        }
      """

      Given url 'https://api.dev.nva.aws.unit.no/publication'

    Scenario: POST returns status Created, Resource detials and Location header
      Given path '/'
      And request correctResourcePayload
      When method POST
      Then status 201
      And match response.identifier == '#present'
      And match header Location == '#present'

    Scenario: POST returns status Unauthorized when unauthorized user
      Given path '/'
      * configure headers = {Authorization: 'unauthorized' }
      And request correctResourcePayload
      When method POST
      Then status 401
      And match response.status == 401
      And match header.title == 'Unauthorized'
      And match header.details == 'Unauthorized access'

    Scenario: GET returns Registration and status Ok when requesting existing Registration
      * path '/by-owner'
      * method GET
      * def identifier = findIdentifier(response.publications, mainTitleGet)
      Given path '/' + identifier
      When method GET
      Then status 200

    Scenario: PUT returns status Ok
      * path '/by-owner'
      * method GET
      * def identifier = findIdentifier(response.publications, mainTitleUpdate)
      * set correctResourceUpdatePayload.identifier = identifier
      * set correctResourceUpdatePayload.mainTitle = updatedMainTitle
      Given path '/' + identifier
      And request correctResourceUpdatePayload
      When method PUT
      Then status 200
      And response.mainTitle = updatedMainTitle

    Scenario: DELETE resource returns status Ok
      * path '/by-owner'
      * method GET
      * def identifier = findIdentifier(response.publications, mainTitleDelete)
      Given path '/' + identifier
      When method DELETE
      Then status 202

    Scenario: PUT publish returns status Accepted
      * path '/by-owner'
      * method GET
      * def identifier = findIdentifier(response.publications, mainTitlePublish)
      Given path '/' + identifier + '/publish'
      And request '{}'
      When method PUT
      Then status 202
      And response.message = 'Publication is being published. This may take a while.'
      And response.status = 202

    Scenario: GET returns status Not Found when requesting non-existing Registration
      * karate.log(nonExistingResourceId)
      Given path '/' + nonExistingResourceId
      When method GET
      Then status 404
      And match response.title == 'Not Found'
      And match response.status == 404
      And match response.detail == 'Publication not found: ' + nonExistingResourceId

    Scenario: GET returns status Bad Request when requesting with invalid identifier
      Given path '/' + invalidIdentifier
      When method GET
      Then status 400
      And match response.title == 'Bad Request'
      And match response.status == 400
      And match response.detail == 'The request identifier is invalid: ' + invalidUuid

    Scenario: GET resource by owner returns status Ok
      Given path '/by-owner'
      When method GET
      Then status 200
      And response.publications == '#array'

    Scenario: Post create doirequest returns status Created
      * path '/by-owner'
      * method GET
      * def identifier = findIdentifier(response.publications, mainTitleDoiRequestCreate)
      * set correctDoirequestPayload.identifier = identifier
      Given path '/doirequest'
      And request correctDoirequestPayload
      When method POST
      Then status 201

    Scenario Outline: GET doirequest by role returns status Ok
      Given path '/doirequest'
      And param role = '<Role>'
      When method GET
      Then status 200
      Examples:
        | Role    |
        | Creator |
        | Curator |

    Scenario: POST message returns status Created
      * path '/by-owner'
      * method GET
      * def identifier = findIdentifier(response.publications, mainTitleMessageCreate)
      * set correctMessage.publicationIdentifier = identifier
      Given path '/messages'
      And request correctMessage
      When method POST
      Then status 201

    Scenario Outline: GET messages by role returns status Ok
      * path '/messages'
      * request correctMessage
      * method POST
      Given path '/messages'
      And param role = '<Role>'
      When method GET
      Then status 200
      Examples:
        | Role    |
        | Creator |
        | Curator |

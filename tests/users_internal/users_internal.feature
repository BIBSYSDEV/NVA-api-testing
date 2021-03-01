Feature: Users internal API

    Background:
        * def getResponse = read('../../test_files/nva_users_internal/get_success.json')
        * def postSuccessPayload = read('../../test_files/nva_users_internal/post_success_payload.json')
        * def postResponse = read('../../test_files/nva_users_internal/post_response.json')
        * def existingUserPayload = read('../../test_files/nva_users_internal/post_existing_user_payload.json')
        * def missingTypePayload = read('../../test_files/nva_users_internal/post_missing_type_payload.json')
        * def wrongTypePayload = read('../../test_files/nva_users_internal/post_wrong_type_payload.json')
        * def wrongRoleTypePayload = read('../../test_files/nva_users_internal/post_wrong_role_type_payload.json')
        * def putSuccessPayload = read('../../test_files/nva_users_internal/put_success_payload.json')
        * def getUser = 'user-internal-get@test.no'
        * def putUser = 'user-internal-put@test.no'
        * def nonExistingUser = 'non-existing-user'

    Given url 'https://api.dev.nva.aws.unit.no/users-roles-internal/service/users/'

    Scenario: GET returns User details and status OK when requesting existing User
        Given path getUser
        When method get
        Then status 200
        And match response == getResponse

    Scenario: GET returns status Not Found when requesting non-existing user
        Given path nonExistingUser
        When method get
        Then status 404
        And match response.status == 404
        And match response.title == 'Not Found'
        And match response.detail == 'Could not find user with username: ' + nonExistingUser

    Scenario: POST returns User details and status OK when posting correct User payload
        Given path '/'
        And request postSuccessPayload
        When method post
        Then status 200
        And match response == postResponse

    Scenario: POST returns status User already exists when posting User with already existing username 
        Given path '/'
        And request existingUserPayload
        When method post
        Then status 409
        And match response.status == 409
        And match response.title == 'Conflict'
        And match response.detail == 'User already exists: ' + getUser

    Scenario: POST returns status JSON object is missing a type attribute when User payload is missing Type attribute
        Given path '/'
        And request missingTypePayload
        When method POST
        Then status 400
        And match response.status == 400
        And match response.title == 'Bad Request'
        And match response.detail == 'JSON object is missing a type attribute'
    
    Scenario: POST returns status JSON object is missing a type attribute when User payload has an invalid Type attribute
        Given path '/'
        And request wrongTypePayload
        When method POST
        Then status 400
        And match response.status == 400
        And match response.title == 'Bad Request'
        And match response.detail == 'JSON object is missing a type attribute'
    
    Scenario: POST returns status JSON object is missing a type attribute when User payload has an invalid Role Type attribute
        Given path '/'
        And request wrongRoleTypePayload
        When method POST
        Then status 400
        And match response.status == 400
        And match response.title == 'Bad Request'
        And match response.detail == 'JSON object is missing a type attribute'
    
    Scenario: PUT returns status Success when updating an existing User with correct payload
        Given path putUser
        When method GET
        Then status 200
        And match response.givenName == 'User internal PUT'

        When path putUser
        And request putSuccessPayload
        And method PUT
        Then status 202

        When path putUser
        And method GET
        Then status 200
        And match response.givenName == 'User internal PUT Changed'


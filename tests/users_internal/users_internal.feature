Feature: Users internal API

    Background:
        * def getResponse = read('../../test_files/nva_users_internal/get_success.json')
        * def postSuccessPayload = read('../../test_files/nva_users_internal/post_success_payload.json')
        * def postResponse = read('../../test_files/nva_users_internal/post_response.json')
        * def existingUserPayload = read('../../test_files/nva_users_internal/post_existing_user_payload.json')
        * def missingTypePayload = read('../../test_files/nva_users_internal/post_missing_type_payload.json')
        * def putSuccessPayload = read('../../test_files/nva_users_internal/put_success_payload.json')
        * def getUser = 'user-internal-get@test.no'
        * def putUser = 'user-internal-put@test.no'
        * def notExistingUser = 'not-existing-user'

    Given url 'https://api.dev.nva.aws.unit.no/users-roles-internal/service/users/'

    Scenario: GET user success
        Given path getUser
        When method get
        Then status 200
        And match response == getResponse

    Scenario: GET user not found
        Given path notExistingUser
        When method get
        Then status 404
        And match response.title == 'Not Found'
        And match response.detail == 'Could not find user with username: ' + notExistingUser

    Scenario: POST user success
        Given path '/'
        And request postSuccessPayload
        When method post
        Then status 200
        And match response == postResponse

    Scenario: POST user allready exist
        Given path '/'
        And request existingUserPayload
        When method post
        Then status 409
        And match response.title == 'Conflict'
        And match response.detail == 'User already exists: ' + getUser

    Scenario: POST missing type attribute
        Given path '/'
        And request missingTypePayload
        When method POST
        Then status 400
        And match response.title == 'Bad Request'
        And match response.detail == 'JSON object is missing a type attribute'
    
    Scenario: PUT success
        Given path putUser
        And method GET
        Then status 200
        And match response.givenName == 'User internal PUT'

        Given path putUser
        And request putSuccessPayload
        And method PUT
        Then status 202

        Given path putUser
        And method GET
        Then status 200
        And match response.givenName == 'User internal PUT Changed'


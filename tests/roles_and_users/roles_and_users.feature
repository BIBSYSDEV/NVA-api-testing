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
      * def findCustomer = 
      """
        function(shortName, customerList) {
          var customerId = 'not found'
          customerList.forEach(function(customer) {
            if(customer['shortName'] === shortName) {
              customerId = customer['identifier'];
            }
          });
          return customerId
        }
      """

      * url 'http://api.dev.nva.aws.unit.no/customer'
      * path '/'
      * method GET
      * def customerId = findCustomer('UNIT', response.customers)
      * def customer = 'https://api.dev.nva.aws.unit.no/customer/' + customerId

      * def createRolePayload = read('../../test_files/users_and_roles/create_role_payload.json')
      * def existingRolePayload = read('../../test_files/users_and_roles/existing_role_payload.json')
      * def createUserPayload = read('../../test_files/users_and_roles/create_user_payload.json')
      * set createUserPayload['institution'] = customer
      * def responseBodyUser = read('../../test_files/users_and_roles/create_user_response.json')
      * set responseBodyUser['institution'] = customer
      * def existingUserPayload = read('../../test_files/users_and_roles/existing_user_payload.json')
      * set existingUserPayload['institution'] = customer
      * def createUpdateUserPayload = read('../../test_files/users_and_roles/create_update_user_payload.json')
      * set createUpdateUserPayload['institution'] = customer
      * def updateUserPayload = read('../../test_files/users_and_roles/update_user_payload.json')
      * set updateUserPayload['institution'] = customer

      Given url 'https://api.dev.nva.aws.unit.no/users-roles'

    Scenario: GET Users for institution returns list of Users
      * def user = 
      """
        { 
          type: 'User', 
          roles: '#array', 
          username: '#string', 
          institution: '#string', 
          givenName: '#string', 
          familyName: '#string', 
          accessRights: '#array' 
        }
      """
      * url 'https://api.dev.nva.aws.unit.no/users-roles'
      Given path '/institutions/users'
      And param institution = customer
      When method GET
      Then status 200
      And match response =='#array' 
      And match response == '#(^*user)'

    Scenario: POST Roles returns posted Role
      Given path '/roles'
      And request createRolePayload
      When method POST
      Then status 200
      And match response == createRolePayload

    Scenario: POST roles with existing Role returns Conflict
      Given path '/roles'
      And request existingRolePayload
      When method POST
      Then status 409
      And match response.status == 409
      And match response.title == 'Conflict'
      And match response.detail == 'Role already exists: ' + existingRolePayload.rolename

    Scenario: GET Role by role name returns Role
      * def roleName = 'TestExistingRole'
      Given path '/roles/' + roleName
      When method GET
      Then status 200
      And match response == existingRolePayload

    Scenario: GET Role by non-existing role name returns Not Found
      * def nonExistingRoleName = 'TestNonExistingRole'
      Given path '/roles/' + nonExistingRoleName
      When method GET
      Then status 404
      And match response.status == 404
      And match response.title == 'Not Found'
      And match response.detail == 'Could not find role: ' + nonExistingRoleName

    Scenario: POST User returns posted User
      Given path '/users'
      And request createUserPayload
      When method POST
      Then status 200
      And match response == responseBodyUser

    Scenario: Post User with existing User returns Conflict
      Given path '/users'
      And request existingUserPayload
      When method POST
      Then status 409
      And match response.status == 409
      And match response.title == 'Conflict'
      And match response.detail == 'User already exists: ' + existingUserPayload.username

    Scenario: GET existing User by username returns User
      * def username = 'test-user-api-create-user@test.no'
      Given path '/users/' + username
      When method GET
      Then status 200
      And match response == createUserResponse

    Scenario: GET non-existing User returns Not Found
      * def nonExistingUsername = 'non-existing-user'
      Given path '/users/' + nonExistingUsername
      When method GET
      Then status 404
      And match response.status == 404
      And match response.title == 'Not Found'
      And match response.detail == 'Could not find user with username: ' + nonExistingUsername

    Scenario: PUT updates existing User and returns Accepted
      * path '/users'
      * request createUpdateUserPayload
      * method POST
      * status 200
      * def username = 'test-user-api-update-user@test.no'
      Given path '/users/' + username
      And request updateUserPayload
      When method PUT
      Then status 202

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
      * def createRolePayload = 
      """
          {
              accessRights: [
                  "READ_DOI_REQUEST"
              ],
              rolename: "TestCreateRole",
              type: "Role"
          }
      """
      * def createUserPayload = 
      """
          {
            "institution": "https://api.dev.nva.aws.unit.no/customer/9c1c941f-c713-4900-8482-f7d2684fc630",
            "roles": [
                {
                "rolename": "Creator",
                "type": "Role"
                }
            ],
            "familyName": "TestUser",
            "givenName": "API Create User",
            "type": "User",
            "username": "test-user-api-create-user@test.no"
          }
      """
      * def createUserResponse = 
      """
          {
            "institution": "https://api.dev.nva.aws.unit.no/customer/9c1c941f-c713-4900-8482-f7d2684fc630",
            "accessRights": [
                "READ_DOI_REQUEST"
            ],                
            "roles": [
              {
                "accessRights": [
                  "READ_DOI_REQUEST"
                ],                
                "rolename": "Creator",
                "type": "Role"
              }
            ],
            "familyName": "TestUser",
            "givenName": "API Create User",
            "type": "User",
            "username": "test-user-api-create-user@test.no"
          }
      """
      * def createUpdateUserPayload = 
      """
          {
            "institution": "https://api.dev.nva.aws.unit.no/customer/9c1c941f-c713-4900-8482-f7d2684fc630",
            "roles": [
                {
                "rolename": "Creator",
                "type": "Role"
                }
            ],
            "familyName": "TestUser",
            "givenName": "API User To Be Updated",
            "type": "User",
            "username": "test-user-api-update-user@test.no"
          }
      """
      * def updateUserPayload = 
      """
          {
            "institution": "https://api.dev.nva.aws.unit.no/customer/9c1c941f-c713-4900-8482-f7d2684fc630",
            "roles": [
                {
                "rolename": "Creator",
                "type": "Role"
                }
            ],
            "familyName": "TestUser",
            "givenName": "API Updated User",
            "type": "User",
            "username": "test-user-api-update-user@test.no"
          }
      """

      Given url 'https://api.dev.nva.aws.unit.no/users-roles'

    Scenario: GET user for institution returns list of Users
      * url 'http://api.dev.nva.aws.unit.no/customer'
      * path '/'
      * method GET
      * def customerId = findCustomer('UNIT', response.customers)
      * def user = { type: 'User', roles: '#array', username: '#string', institution: '#string', givenName: '#string', familyName: '#string', accessRights: '#array' }
      * url 'https://api.dev.nva.aws.unit.no/users-roles'
      Given path '/institutions/users'
      And param institution = 'https://api.dev.nva.aws.unit.no/customer/' + customerId
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
      And request createRolePayload
      When method POST
      Then status 409
      And match response.status == 409
      And match response.title == 'Conflict'
      And match response.detail == 'Role already exists: ' + createRolePayload.rolename

    Scenario: GET Role by role name returns Role
      * def roleName = 'TestCreateRole'
      Given path '/roles/' + roleName
      When method GET
      Then status 200
      And match response == createRolePayload

    Scenario: GET Role by non-existing role name returns Not Found
      * def nonExistingRoleName = 'NonExistingRole'
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
      And match response == createUserResponse

    Scenario: Post User with existing User returns Conflict
      Given path '/users'
      And request createUserPayload
      When method POST
      Then status 409
      And match response.status == 409
      And match response.title == 'Conflict'
      And match response.detail == 'User already exists: ' + createUserPayload.username

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

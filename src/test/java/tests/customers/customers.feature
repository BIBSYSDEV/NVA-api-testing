Feature: Tests for NVA customers API

Background:
  Given url SERVER_URL + 'customer'
  * def orgNumber = '1234567890'
  * def cristinId = 'https://api.cristin.no/v2/institutions/0987654321'
  * def badlyFormedCustomerId = 'i-am-badly-formed'
  * def headers = call read('classpath:tests/common.feature@header')
  * configure headers = headers.header
  * def postSuccessPayload = read('classpath:test_files/nva_customers/post_success_payload.json')
  * def getCustomerIdSuccessResponse = read('classpath:test_files/nva_customers/get_customer_id_success_response.json')
  * def getOrgNrSuccessResponse = read('classpath:test_files/nva_customers/get_org_nr_success_response.json')
  * def getCristinIdSuccessResponse = read('classpath:test_files/nva_customers/get_cristin_id_success_response.json')
  * def putSuccessPayload = read('classpath:test_files/nva_customers/put_success_payload.json')
  * def putSuccessResponse = read('classpath:test_files/nva_customers/put_success_response.json')

Scenario: GET returns status Ok and array of all Customers
  Given path '/'
  When method GET
  Then status 200
  And match response.customers == '#present'
  And match response.customers == '#array'

Scenario: POST returns status Created and Customer details
  Given path '/'
  * def auth_token = 'Bearer ' + BEARER_TOKEN
  * configure headers =
  """
    {
      Authorization: '#(auth_token)',
      Accept: 'application/ld+json',
      'Content-Type': 'application/json',
    }
  """
  And request postSuccessPayload
  When method POST
  Then status 201
  And match header Content-Type == 'application/ld+json'
  And match response.identifier == '#uuid'

Scenario: POST with malformed json returns status Bad Request
  * def malformedJson = '{"bad json", "some": "data"}'
  Given path '/'
  And request malformedJson
  When method POST
  Then status 400
  And match response.title == 'Bad Request'

Scenario: GET by Customer id returns status OK and Customer details
  * def customer = call read('classpath:tests/common.feature@findCustomer') {shortName: 'TEST_CUSTOMER_GET_BY_ID'}
  Given path '/' + customer.customerId
  When method GET
  Then status 200
  And match response contains getCustomerIdSuccessResponse

Scenario: GET by non-existing Customer id returns status Not Found
  * def nonExistingCustomerId = java.util.UUID.randomUUID()
  Given path '/' + nonExistingCustomerId
  When method GET
  Then status 404
  And match response.title == 'Not Found'
  And match response.detail == 'Customer not found: ' + nonExistingCustomerId

Scenario: GET by badly formed Customer id returns status Bad Request
  Given path '/' + badlyFormedCustomerId
  When method GET
  Then status 400
  And match response.title == 'Bad Request'
  And match response.detail == 'Identifier is not a valid UUID: ' + badlyFormedCustomerId

Scenario: GET by OrgNr returns status OK and Customer details
  Given path '/orgNumber/' + orgNumber
  When method GET
  Then status 200
  And match response == getOrgNrSuccessResponse

Scenario: GET by CristinId returns status OK and Customer details
  Given path '/cristinId/' + cristinId
  When method GET
  Then status 200
  And match response == getCristinIdSuccessResponse

Scenario: PUT returns status Accepted when updating an existing Customer with correct payload
  * path '/'
  * method GET
  * def customer = call read('classpath:tests/common.feature@findCustomer') {shortName: 'TEST_CUSTOMER_UPDATE'}
  * set putSuccessPayload.identifier = customer.customerId
  Given path '/' + customer.customerId
  And request putSuccessPayload
  When method PUT
  Then status 200
  * set putSuccessResponse.identifier = customer.customerId
  * set putSuccessResponse.id = SERVER_URL + 'customer/' + customer.customerId
  And match response contains putSuccessResponse

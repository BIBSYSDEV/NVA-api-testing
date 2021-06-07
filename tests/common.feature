Feature: Common functions for API tests

Background:
  * def readCustomers =
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

# Usage: * def header = call read('classpath:tests/common.feature@header')
@header
Scenario: header
  * def auth_token = 'Bearer ' + BEARER_TOKEN
  * def header =
  """
    {
      Authorization: '#(auth_token)',
      Accept: 'application/json'
    }
  """

# Usage: * def customer = call read('classpath:tests/common.feature@findCustomer') {shortName: '<shortName>' }
@findCustomer
Scenario: Find customer by shortName
  * url 'http://api.sandbox.nva.aws.unit.no/customer'
  * path '/'
  * method GET
  * def customerId = readCustomers(shortName, response.customers)

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
    @name=findCustomer
    Scenario: Find customer by shortName
        * url 'http://api.dev.nva.aws.unit.no/customer'
        * path '/'
        * method GET
        * def customerId = readCustomers(__arg.shortName, response.customers)


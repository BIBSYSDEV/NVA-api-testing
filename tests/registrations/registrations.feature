    * def auth_token = 'Bearer ' + BEARER_TOKEN
    * def orgNumber = '1234567890'
    * def cristinId = 'https://api.cristin.no/v2/institutions/0987654321'
    * def badlyFormedCustomerId = '082414df-1130-4d7c-b744-bdc1a6242cad'
    * configure headers = 
    """
      { 
        Authorization: '#(auth_token)',
        Accept: 'application/json'
      }
    """
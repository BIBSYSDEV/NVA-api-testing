Feature: Tests for NVA customers API

  Background:
    Given url 'https://api.dev.nva.aws.unit.no/customer'
    * def auth_token = 'Bearer ' + BEARER_TOKEN
    * headers {Authorization: auth_token, Accept: 'application/json'}

  Scenario: GET returns array of all customers
    Given path '/'
    When method GET
    Then response match '#array'

Feature: API tests for public search

  Background:
    * def testTitleSearchTerm = 'API_test_public_search'

    Given url 'https://api.dev.nva.aws.unit.no/search'

    Scenario: GET resources returns list of search results
      Given path '/resources'
      When method GET
      Then status 200
      And match response.hits == '#array'
      And match response.total == '#number'

    Scenario: GET resources with query returns list of search results
      Given path '/resources'
      And param query = testTitleSearchTerm
      When method GET
      Then status 200
      And match response.hits == '#[6]' // hits array length == 6
      And match response.total == 6

    Scenario: GET resources with query returns list of 3 resources when 'results=3'
      Given path '/resources'
      And param query = testTitleSearchTerm
      And param results = 3
      When method GET
      Then status 200
      And match response.hits == '#[3]' // hits array length == 3
      And match response.total == 6

    Scenario: GET resources with query returns list of 2 resources when 'from=4'
      Given path '/resources'
      And param query = testTitleSearchTerm
      And param from = 4
      When method GET
      Then status 200
      And match response.hits == '#[2]' // hits array length == 2
      And match response.total == 6

    Scenario: GET resources with query returns list of 2 resources when 'from=4' and 'results=3'
      Given path '/resources'
      And param query = testTitleSearchTerm
      And param from = 4
      And param results = 3
      When method GET
      Then status 200
      And match response.hits == '#[2]' // hits array length == 2
      And match response.total == 6

    Scenario: GET resources with query returns list of 3 resources when 'from=2' and 'results=3'
      Given path '/resources'
      And param query = testTitleSearchTerm
      And param from = 2
      And param results = 3
      When method GET
      Then status 200
      And match response.hits == '#[3]' // hits array length == 3
      And match response.total == 6

    Scenario: GET resources with query returns list sorted on 

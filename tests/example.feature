Feature: Testing search

  Background:
    Given url 'https://api.dev.nva.aws.unit.no'

  Scenario: Search for 'ibsen'
    Given path 'search/resources' 
    And param query = 'ibsen'
    # And request = { query: 'ibsen' }
    # And request = read('query.json')
    When method get
    Then status 200
    And match response == '#array'
    And match response[0].type == 'BookMonograph'
    And match response[0].date == '#present'
    And match response[0].id == '#uuid'

  Scenario: Search for 'something'
    Given path 'search/resources' 
    And param query = 'something'
    When method get
    Then status 200
    And match response == '#array'
		And match response.size() == 0

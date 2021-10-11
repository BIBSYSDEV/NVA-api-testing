Feature: Testing search

Background:
  Given url 'https://api.dev.nva.aws.unit.no'

Scenario: Search for '*'
  Given path 'search/resources'
  And param query = '*'
  # And request = { query: '*' }
  # And request = read('query.json')
  When method get
  Then status 200
  And match response == '#object'
  And match response.hits == '#array'
  And match response.hits[0].publicationDate == '#present'
  And match response.hits[0].id == '#uuid'

Scenario: Search for 'something'
  Given path 'search/resources'
  And param query = 'something'
  When method get
  Then status 200
  And match response == '#object'
  And match response.total == 0

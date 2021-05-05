Feature: Public search API tests

  Background:

    * def searchResult =
    """
        {
  "owner": "#string",
  "publicationType": "#string",
  "description": "#string",
  "abstract": "#string",
  "title": "#string",
  "tags": '#array',
  "reference": {
    "publicationInstance": {
      "volume": "#string",
      "pages": {
        "illustrated": true,
        "pages": "#string",
        "end": "#string",
        "type": "#string",
        "begin": "#string"
      },
      "issue": "#string",
      "articleNumber": "#string",
      "textbookContent": true,
      "peerReviewed": true,
      "type": "#string"
    },
    "type": "#string",
    "publicationContext": {
      "level": "#string",
      "openAccess": true,
      "peerReviewed": true,
      "publisher": "#string",
      "linkedContext": "#string",
      "title": "#string",
      "onlineIssn": "#string",
      "type": "#string",
      "printIssn": "#string",
      "url": "#string",
      "seriesTitle": "#string"
    },
    "doi": "#string"
  },
  "modifiedDate": "#string",
  "publisher": {
    "name": "#string",
    "id": "#string"
  },
  "contributors": '#array',
  "publishedDate": "#string",
  "id": "#string",
  "publicationDate": {
    "month": "#string",
    "year": "#string",
    "type": "#string",
    "day": "#string"
  },
  "alternativeTitles": '#array',
  "doi": "#string"
}
    """

    Given url 'https://api.dev.nva.aws.unit.no/search'

    Scenario: GET returns list of search results
      Given path '/resources'
      When method GET
      Then status 200
      And match response['@context'] == '#present'
      And match response.took == '#number'
      And match response.total == '#number'
      And match response.hits == '#array'

    Scenario: GET returns list of 5 results when called with query param 'results=5'
      Given path '/resources'
      And param results = 5
      When method GET
      Then status 200
      And match response.hits == '#array'

    Scenario: GET returns list of search results when called with query param 'query="API public search"'
      Given path '/resources'
      And param query = 'API AND public'
      When method GET
      Then status 200
      And match response.hits == '#array'
      And match response.hits == '#[5]'

      
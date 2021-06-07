Feature: Fetch DOI API tests

Background:
  Given url SERVER_URL + 'doi-fetch'
  * def headers = call read('classpath:tests/common.feature@header')
  * configure headers = headers.header
  * def correct_doi_response =
  """
    {
      "date": {
        "month": "#present",
        "year": "#present",
        "day": "#present"
      },
      "identifier": "#present",
      "creatorName": "#present",
      "title": "#present"
    }
  """
  * def doi_url = 'https://doi.org/10.1103/physrevd.100.085005'

Scenario: POST with existing DOI returns Status OK
  Given path ''
  And request { doiUrl: #(doi_url) }
  When method POST
  Then status 200
  And match response == correct_doi_response

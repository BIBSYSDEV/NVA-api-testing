Feature: Fetch DOI API tests

  Background:
    * def auth_token = 'Bearer ' + BEARER_TOKEN
    * configure headers =
    """
        {
            Accept: 'application/json',
            Authorization: #(auth_token)
        }
    """
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
    Given url 'https://api.sandbox.nva.aws.unit.no/doi-fetch'

    Scenario: POST with existing DOI returns Status OK
    Given path ''
    And request { doiUrl: #(doi_url) }
    When method POST
    Then status 200
    And match response == correct_doi_response
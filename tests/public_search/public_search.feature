Feature: API tests for public search

  Background:
    * def testTitleSearchTerm = 'API_test_public_search'
    * def sortList = 
    """
      (list, sortOrder) => {
        let Collections = Java.type('java.util.Collections')
        if (sortOrder === 'desc') {
          Collections.sort(list, Collections.reverseOrder())
        } else {
          Collections.sort(list)
        }
        return list
      }
    """

    Given url 'https://api.dev.nva.aws.unit.no/search'

    Scenario: GET resources returns list of search results
      Given  path '/resources'
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

    Scenario Outline: GET resources with query returns list sorted by index ascending
      Given path '/resources'
      And param query = testTitleSearchTerm
      And param results = 4
      And param sortedBy = '<index>'
      And param sortOrder = 'asc'
      When method GET
      Then status 200
      * def modifiedDates = $response.hits[*]['<index>']
      * eval modifiedDatesCopy = [...modifiedDates]
      * sortList(modifiedDatesCopy)
      And match modifiedDates == modifiedDatesCopy
      Examples:
      | index         |
      | modifiedDate  |
      | publishedDate |

    Scenario Outline: GET resources with query returns list sorted by index descending
      Given path '/resources'
      And param query = testTitleSearchTerm
      And param results = 4
      And param sortedBy = '<index>'
      And param sortOrder = 'desc'
      When method GET
      Then status 200
      * def modifiedDates = $response.hits[*]['<index>']
      * eval modifiedDatesCopy = [...modifiedDates]
      * sortList(modifiedDatesCopy, 'desc')
      And match modifiedDates == modifiedDatesCopy
      Examples:
      | index         |
      | modifiedDate  |
      | publishedDate |

    Scenario Outline: GET resource with query on indexed field returns list of search results
    Given path '/resources'
    And param query = '<index>:<search>'
    When method GET
    Then status 200
    And match response.hits == '#[6]'
    Examples:
    | index                                           | search                         |
    | abstract                                        | public_search_abstract         |
    | contributors.name                               | public_search_contributor_name |   
    | description                                     | public_search_description      |
    | doi                                             | public_search_doi              |
    | modifiedDate                                    | 2020-01-01                     |
    | owner                                           | public_search_owner@test.no    |
    | publicationDate.day                             | 01                             |
    | publicationDate.month                           | 01                             |
    | publicationDate.type                            | public_search_publ_date_type   |
    | publicationDate.year                            | 2222                           |
    | publishedDate                                   | 2020-01-01                     |
    | publisher.id                                    | <id>                           |
    | reference.doi                                   | public_search_reference_doi    |
    | reference.publicationContext.isbnList           | public_search_isbn             |
    | reference.publicationContext.level              | public_search_level            |
    | reference.publicationContext.linkedContext      | public_search_linked_context   |
    | reference.publicationContext.onlineIssn         | public_search_online_issn      |
    | reference.publicationContext.openAccess         | true                           |
    | reference.publicationContext.peerReviewed       | true                           |
    | reference.publicationContext.printIssn          | public_search_print_issn       |
    | reference.publicationContext.publisher          | public_search_publisher        |
    | reference.publicationContext.seriesTitle        | public_search_series_title     |
    | reference.publicationContext.title              | public_search_title            |
    | reference.publicationContext.type               | public_search_type             |
    | reference.publicationContext.url                | public_search_url              |
    | reference.publicationInstance.articleNumber     | public_search_article          |
    | reference.publicationInstance.issue             | public_search_issue            |
    | reference.publicationInstance.pages.begin       | public_search_pages_begin      |
    | reference.publicationInstance.pages.end         | public_search_pages_end        |
    | reference.publicationInstance.pages.illustrated | public_search_pages_end        |
    | reference.publicationInstance.pages.pages       | public_search_pages_pages      |
    | reference.publicationInstance.pages.type        | public_search_pages_type       |
    | tags                                            | public_search_tags             |
    | title                                           | public_search_title            |
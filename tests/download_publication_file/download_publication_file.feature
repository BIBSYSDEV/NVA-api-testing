Feature: Test for download publication file API

Background:
  Given url SERVER_URL + 'download'
  * def file_create_result = callonce read('registration_create.feature@upload_file')
  * def file_identifier = file_create_result.location
  * def filesize = file_create_result.filesize
  * def registration_create_result = callonce read('registration_create.feature@create_registration') { file_identifier: #(file_identifier), filesize: #(filesize)}
  * def identifier = registration_create_result.identifier

  * def headers = call read ('classpath:/tests/common.feature@header')
  * configure headers = headers.header

Scenario: GET /public with identifier and fileIdentifier returns status OK and presignedDownloadUrl
  * def download_url = (`/public/${identifier}/files/${file_identifier}`)
  Given path download_url
  When method GET
  Then status 200
  And match response.presignedDownloadUrl == '#present'

Scenario: GET with identifier and fileIdentifier returns status OK and presignedDownloadUrl
  * def download_url = (`/${identifier}/files/${file_identifier}`)
  Given path download_url
  When method GET
  Then status 200
  And match response.presignedDownloadUrl == '#present'

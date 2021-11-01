# NVA-api-testing

### Karate documentation:

[Karate](https://karatelabs.github.io/karate/)
[Getting started](https://karatelabs.github.io/karate/#getting-started)

### AWS

CloudFormation template in [/templates](https://github.com/BIBSYSDEV/NVA-api-testing/blob/develop/templates/api_test_deploy.yml)

### Run tests locally:

`./gradlew test 
-Dusername=<username> 
-DuserPoolId=<userPoolId> 
-DclientId=<clientId> 
-DserverUrl=<serverUrl>`

- requires jre 8 or higher

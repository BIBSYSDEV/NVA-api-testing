# NVA-api-testing

### Karate documentation:

[Karate](https://intuit.github.io/karate)
[Getting started](https://intuit.github.io/karate#getting-started)

### AWS

CloudFormation template in [/templates](https://github.com/BIBSYSDEV/NVA-api-testing/blob/develop/templates/api_test_deploy.yml)

### Run tests locally:

`./gradlew test 
-Dusername=<username> 
-DuserPoolId=<userPoolId> 
-DclientId=<clientId> 
-DserverUrl=<serverUrl>`

- requires jre 8 or higher

# NVA-api-testing

### Karate documentation:

[Karate](https://intuit.github.io/karate)
[Getting started](https://intuit.github.io/karate#getting-started)

### AWS

CloudFormation template in [/templates](https://github.com/BIBSYSDEV/NVA-api-testing/blob/develop/templates/api_test_deploy.yml)

### Run tests locally:

linux:

'java -cp karate.jar:. com.intuit.karate.Main tests'

windows:

'java -cp "karate.jar;." com.intuit.karate.Main tests'
- requires jre 8 or higher

function setup() {
  var auth = karate.read('classpath:auth.json');
  var config = {
    BEARER_TOKEN: auth.BEARER_TOKEN,
    SERVER_URL: 'https://api.sandbox.nva.aws.unit.no/',
    CURRENT_ENVIRONMENT: 'sandbox',
  };
  return config;
}

function setup() {
  karate.log('Testing...');
  var auth = karate.read('../../auth.json');
  var config = {
    BEARER_TOKEN: auth.BEARER_TOKEN,
  };
  return config;
}

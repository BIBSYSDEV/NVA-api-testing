function setup() {
  let authentication = Java.type('nva.api.testing.AuthenticationMethods');
  let username = karate.properties['username'];
  let client_id = karate.properties['clientId'];
  let user_pool_id = karate.properties['userPoolId'];
  let id_token = authentication.getIdToken(username, client_id, user_pool_id)
  let server_url = karate.properties['serverUrl']
  let config = {
    BEARER_TOKEN: id_token,
    SERVER_URL: server_url,
  };
  return config;
}

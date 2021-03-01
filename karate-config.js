import { AWS } from 'aws-sdk'

function setup() {
    const cognitoServiceProvider = new AWS.CognitoServiceProvider();
    cognitoServiceProvider.
    karate.log('Setting up...');
    return {
       bearerToken: 'bearer',
   } 
}
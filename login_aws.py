import boto3
import os
import uuid

ssm = boto3.client('ssm')
USER_POOL_ID = ssm.get_parameter(Name='/test/AWS_USER_POOL_ID',
                                 WithDecryption=False)['Parameter']['Value']
CLIENT_ID = ssm.get_parameter(Name='/test/AWS_USER_POOL_WEB_CLIENT_ID',
                              WithDecryption=False)['Parameter']['Value']
client = boto3.client('cognito-idp')


def login(username):
    password = 'P%-' + str(uuid.uuid4())
    response = client.admin_set_user_password(
        Password=password,
        UserPoolId=USER_POOL_ID,
        Username=username,
        Permanent=True,
    )
    response = client.admin_initiate_auth(
        UserPoolId=USER_POOL_ID,
        ClientId=CLIENT_ID,
        AuthFlow='ADMIN_USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': username,
            'PASSWORD': password
        })
    return response['AuthenticationResult']['IdToken']


def find_user(email):
    response = client.list_users(UserPoolId=USER_POOL_ID)
    for cognito_user in response['Users']:
        for attribute in cognito_user['Attributes']:
            if attribute['Name'] == 'email' and attribute['Value'] == email:
                return email
    print('User with email {} not found'.format(email))
    return ''


def run():
    username = find_user(email='api-test-user@test.no')
    if username != '':
        bearer_token = login(username=username)
        print(bearer_token)


if __name__ == '__main__':
    run()
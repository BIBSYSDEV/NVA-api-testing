#!/bin/bash

USER_POOL_ID=eu-west-1_oQvH8xp7L
USERNAME=test-user-curator@test.no
APP_CLIENT_ID=1b8658du35m9ktcfcdogc219nq

echo "Checking if user exists..."
aws cognito-idp admin-get-user --user-pool-id $USER_POOL_ID --username $USERNAME >/dev/null
STATUS=$?
if [ $STATUS -ne 0 ]; then
  # user does not exist, creating user
  echo "Creating user..."
  aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID --username $USERNAME
fi

# generating password
echo 'Generating password...'
export PASSWORD=$(pwgen -y -N 1)

# set password on user
echo 'Setting user password...'
aws cognito-idp admin-set-user-password --user-pool-id $USER_POOL_ID --username $USERNAME --password $PASSWORD --permanent

# initiate auth and export id token to env
echo 'Signing in...'
export ID_TOKEN=$(aws cognito-idp admin-initiate-auth --user-pool-id $USER_POOL_ID --client-id $APP_CLIENT_ID --auth-flow ADMIN_USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$PASSWORD | jq -r '.AuthenticationResult.IdToken')
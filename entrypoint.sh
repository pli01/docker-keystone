#!/usr/bin/env bash


# Init the arguments
CONFIG_FILE=/etc/keystone/keystone.conf
ADMIN_TOKEN=${ADMIN_TOKEN-`openssl rand -hex 10`}

##
admin_username=${KEYSTONE_USERNAME:-"admin"}
admin_password=${KEYSTONE_PASSWORD:-"s3cr3t"}
admin_project=${KEYSTONE_PROJECT:-"admin"}
admin_role=${KEYSTONE_ROLE:-"admin"}
admin_service=${KEYSTONE_SERVICE:-"keystone"}
admin_region=${KEYSTONE_REGION:-"RegionOne"}
admin_url=${KEYSTONE_ADMIN_URL:-"http://localhost:35357"}
public_url=${KEYSTONE_PUBLIC_URL:-"http://localhost:5000"}
internal_url=${KEYSTONE_INTERNAL_URL:-"http://localhost:5000"}


# update keystone.conf
sed -i "s#^admin_token.*=.*#admin_token = $ADMIN_TOKEN#" $CONFIG_FILE
mv /etc/keystone/default_catalog.templates /etc/keystone/default_catalog

cd /var/lib/keystone
echo "Init keystone DB"
su keystone -s /bin/sh -c "keystone-manage db_sync"

echo "Creating bootstrap credentials..."
keystone-manage bootstrap \
        --bootstrap-password "$admin_password" \
        --bootstrap-username "$admin_username" \
        --bootstrap-project-name "$admin_project" \
        --bootstrap-role-name "$admin_role" \
        --bootstrap-service-name "$admin_service" \
        --bootstrap-region-id "$admin_region" \
        --bootstrap-admin-url "$admin_url" \
        --bootstrap-public-url "$public_url" \
        --bootstrap-internal-url "$internal_url"
# Write openrc to disk
cat >~/openrc <<EOF
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=$admin_project
export OS_USERNAME=$admin_username
export OS_PASSWORD=${admin_password}
export OS_AUTH_URL=$public_url
export OS_IDENTITY_API_VERSION=3
EOF
cat ~/openrc

sleep 2
echo "Starting keystone to become available at $admin_url..."
/usr/bin/keystone-all

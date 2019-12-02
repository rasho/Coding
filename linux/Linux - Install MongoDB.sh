#!/bin/bash

# ------------------------------------------------------------
# CentOS / RHEL - Install MongoDB


# ------------------------------------------------------------
# Setup & Downlaod the Package Repository & Package (itself)
echo -e "[mongodb-org-4.2]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc\n" > "/etc/yum.repos.d/mongodb-org-4.2.repo"; yum check-update; yum install -y mongodb-org; \
mkdir -p "/var/lib/mongo"; chown -R "mongod:mongod" "/var/lib/mongo"; chmod 0755 "/var/lib/mongo"; \
mkdir -p "/var/lib/mongodb"; chown -R "mongod:mongod" "/var/lib/mongodb"; chmod 0755 "/var/lib/mongodb"; \
service mongod start;


# ------------------------------------------------------------
# Setup IP Address as [ Loopback,LAN ] instead of [ Loopback ]
THIS_IPv4=$(ip addr show | grep 'inet' | grep 'scope global' | awk '{ print $2; }' | sed 's/\/.*$//' | grep '\.'); \
if [ -n "$(cat '/etc/mongod.conf' | grep '127.0.0.1 ';)" ]; then \
sed --in-place=".$(date +'%Y-%m-%d_%H-%M-%S').bak" -e "/^  bindIp: 127.0.0.1 /c\  bindIp: 127.0.0.1,${THIS_IPv4}" "/etc/mongod.conf"; \
cat "/etc/mongod.conf"; service mongod restart; \
fi;

# ------------------------------------------------------------
# Setup access security
echo ""; read -p "Enter Filepath for MongoDB KeyFile:  " -t 60 -r; echo ""; \
if [ -n "${REPLY}" ]; then \
NEW_KEYFILE="${REPLY}"; \
if [ ! -f "${NEW_KEYFILE}" ]; then echo "Warning - file not found: \"${NEW_KEYFILE}\""; read -p "Create a randomly-generated Keyfile, now? (y/n)  " -n 1 -t 60 -r; echo ""; if [[ $REPLY =~ ^[Yy]$ ]]; then openssl rand -base64 741 > "${NEW_KEYFILE}"; fi; fi; \
CURRENT_KEYFILE="$(cat /etc/mongod.conf | grep keyFile | awk '{print $2}')"; \
if [ -z "${CURRENT_KEYFILE}" ]; then \
sed --in-place=".$(date +'%Y-%m-%d_%H-%M-%S').bak" -e '
/^#security:/ {
a\
  keyFile: '${NEW_KEYFILE}'
a\
  authorization: enabled
c\
security:
}' "/etc/mongod.conf"; \
cat "/etc/mongod.conf"; service mongod restart; \
elif [ "${CURRENT_KEYFILE}" != "${NEW_KEYFILE}" ]; then \
echo "Warning:  keyFile currently set to path \"${CURRENT_KEYFILE}\""; read -p "Update keyFile to reference \"${NEW_KEYFILE}\", instead? (y/n)  " -n 1 -t 60 -r; echo ""; if [[ $REPLY =~ ^[Yy]$ ]]; then sed --in-place=".$(date +'%Y-%m-%d_%H-%M-%S').bak" -e "/^  keyFile:/c\  keyFile: ${NEW_KEYFILE}" "/etc/mongod.conf"; cat "/etc/mongod.conf"; service mongod restart; fi; \
else \
echo "Info:  keyFile already set to path \"${CURRENT_KEYFILE}\" in \"/etc/mongod.conf\" - no action required";
fi; \
fi;


# ------------------------------------------------------------
# Setup replication
CURRENT_REPL_SET_NAME="$(cat /etc/mongod.conf | grep replSetName | awk '{print $2}')"; \
CURRENT_REPL_DISABLED="$(cat /etc/mongod.conf | grep '#replication:')"; \
if [ -z "${CURRENT_REPL_SET_NAME}" ] && [ -n "${CURRENT_REPL_DISABLED}" ]; then
echo ""; read -p "Enable replication for MongoDB? (y/n)  " -n 1 -t 60 -r; echo ""; if [[ $REPLY =~ ^[Yy]$ ]]; then \
echo ""; read -p "Enter the name of the replication set to join:  " -t 60 -r; echo ""; if [ -n "${REPLY}" ]; then NEW_REPL_SET_NAME="${REPLY}"; \
sed --in-place=".$(date +'%Y-%m-%d_%H-%M-%S').bak" -e '
/^#replication:/ {
a\
  replSetName: '${NEW_REPL_SET_NAME}'
c\
replication:
}' "/etc/mongod.conf"; \
cat "/etc/mongod.conf"; service mongod restart; \
fi; \
fi; \
fi;


# ------------------------------------------------------------
# Citation(s)
#
#   docs.mongodb.com  |  "Install MongoDB Community Edition on Debian"  |  https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/
#
#   docs.mongodb.com  |  "Install MongoDB Community Edition on Red Hat or CentOS"  |  https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/
#
#   docs.mongodb.com  |  "Install MongoDB Community Edition on Ubuntu"  |  https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
#
#   docs.mongodb.com  |  "Deploy a Replica Set"  |  https://docs.mongodb.com/manual/tutorial/deploy-replica-set/
#
# ------------------------------------------------------------
#!/bin/sh
#
# ------------------------------------------------------------

if [ 1 -eq 1 ]; then

USER_NAME="DAT_USER";

USER_PASS="DAT_PASS"; # Password must have 1*Letter, 1*Number, 1*Special-Char

esxcli system account add -d="${USER_NAME}" -i="${USER_NAME}" -p="${USER_PASS}" -c="${USER_PASS}";

esxcli system permission set --id "${USER_NAME}" --role "Admin";

esxcli system account list;

esxcli system permission list;

fi;


# ------------------------------------------------------------
# Citation(s)
#
#   pubs.vmware.com  |  "vSphere Command-Line Interface Reference"  |  https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vcli.ref.doc_50%2Fvcli-right.html
#
#   pubs.vmware.com  |  "esxcli storage Commands"  |  https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vcli.ref.doc_50%2Fesxcli_storage.html
#
#   pubs.vmware.com  |  "esxcli system Commands"  |  https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vcli.ref.doc_50%2Fesxcli_system.html
#
# ------------------------------------------------------------
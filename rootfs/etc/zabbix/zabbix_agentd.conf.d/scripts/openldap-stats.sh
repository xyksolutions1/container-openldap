#!/command/with-contenv bash
# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

source /container/base/functions/container/init

if [ -z "${BASE_DN}" ]; then
    IFS='.' read -ra BASE_DN_TABLE <<< "$DOMAIN"
    for i in "${BASE_DN_TABLE[@]}"; do
        EXT="dc=$i,"
        BASE_DN=$BASE_DN$EXT
    done
    BASE_DN=${BASE_DN::-1}
fi

transform_var file \
                    ADMIN_PASS

LDAP_PARAM="$1"
LDAP_RESPONSE_KEY="${2:-monitorCounter}"
COMMAND="ldapsearch -H ldap://$HOSTNAME:389 -b $LDAP_PARAM -D cn=admin,$BASE_DN -w $ADMIN_PASS"
RAW=$($COMMAND -s base '(objectClass=*)' '*' '+')
RESULT=$(eval "echo '$RAW' | sed -n 's/^[ \t]*$LDAP_RESPONSE_KEY:[ \t]*\(.*\)/\1/p'")
echo ${RESULT}


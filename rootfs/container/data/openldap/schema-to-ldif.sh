#!/bin/bash

SCHEMAS=$1

tmpd=$(mktemp -d)
pushd "${tmpd}" >>/dev/null

echo "include /etc/openldap/schema/core.schema" | silent tee -a convert.dat
echo "include /etc/openldap/schema/cosine.schema" | silent tee -a convert.dat
echo "include /etc/openldap/schema/nis.schema" | silent tee -a convert.dat
echo "include /etc/openldap/schema/inetorgperson.schema" | silent tee -a convert.dat

for schema in ${SCHEMAS} ; do
    echo "include ${schema}" | silent tee -a convert.dat
done

slaptest -f convert.dat -F .

if [ ${?} -ne 0 ] ; then
    echo "** [openldap] ERROR: slaptest conversion failed!"
    exit
fi

for schema in ${SCHEMAS} ; do
    fullpath=${schema}
    schema_name="$(basename ${fullpath} .schema)"
    schema_dir="$(dirname ${fullpath})"
    ldif_file=${schema_name}.ldif

    find . -name *\}${schema_name}.ldif -exec mv '{}' ./${ldif_file} \;

    sed -i \
                -e "/dn:/ c dn: cn=${schema_name},cn=schema,cn=config" \
                -e "/cn:/ c cn: ${schema_name}" \
                -e "/structuralObjectClass/ d" \
                -e "/entryUUID/ d" \
                -e "/creatorsName/ d" \
                -e "/createTimestamp/ d" \
                -e "/entryCSN/ d" \
                -e "/modifiersName/ d" \
                -e "/modifyTimestamp/ d" \
            "${ldif_file}"

    # slapd seems to be very sensitive to how a file ends. There should be no blank lines.
    sed -i '/^ *$/d' ${ldif_file}

    mv "${ldif_file}" "${schema_dir}"
done

popd >> /dev/null
rm -rf "${tmpd}"

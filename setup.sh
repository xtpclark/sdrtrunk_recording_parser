#!/bin/bash
BASEDIR=$(dirname "$(readlink -f "$0")")
cd $BASEDIR
pwd

WORKDATE=$(date +"%Y%m%d")
WORKSEC=$(date +"%s")

CONF_FILE=psf_settings.ini

PGHOST=${PGHOST:-localhost}


get_port_conf() {
PGCONF=$( which pg_config )

if [[ -z ${PGCONF} ]]; then
echo "pg_config not found"
exit
else

PGBIN=$(pg_config --bindir)

for (( i=5432; i<5450; i+=1 )); do

PG_READY=$( ${PGBIN}/pg_isready -p ${i} )
RES="${?}"
# echo "RES=${RES} ${i}"

if [[ "0" == ${RES} ]]; then
# echo "in res "
PGPORT="${i}"
PGPORTS+=(${i})
# echo "${PGPORT}"
fi

done

VARCNT=$( printf '%s\n' "${PGPORTS[@]}" | wc -w )

if [[ ${VARCNT} == "0" ]]; then
  echo "
  Found no postgres ports. Is it running?
  Configuring PSF for default of 5432.
  "

 CONF_PGPORT=${PGPORT:-5432}

fi

if [[ ${VARCNT} == "1" ]]; then
  echo "Found an open pg port on ${PGPORTS}"

  CONF_PGPORT="${PGPORTS}"
fi

if [[ ${VARCNT} -gt "1" ]]; then

max=${PGPORTS[0]}
for n in "${PGPORTS[@]}" ; do
    ((n > max)) && max=$n
done

CONF_PGPORT="${max}"

echo "
Found multiple PostgreSQL ports active on: ${PGPORTS[@]}.
Configuring PSF for highest port: ${CONF_PGPORT}
"

fi
fi
}

get_pg_user() {
echo "In pg_get_user"
PGADMINUSER=${PGADMINUSER:-postgres}
PGUSER=${PGUSER:-psfadmin}
}

get_pg_database() {
PGDATABASE=${PGDATABASE:-psf}
}

check_setup_ini() {
CONF_MOVED="${CONF_FILE}_${WORKSEC}"

if [[ -s ${CONF_FILE} ]]; then
echo "${CONF_FILE} exists, moving it to ${CONF_MOVED}"
mv ${CONF_FILE} ${CONF_MOVED}

fi
do_setup_ini
}

do_setup_ini() {
echo "${CONF_FILE} does not exist, creating it."

cat << _EOF_ > ${CONF_FILE}

### PostgreSQL Configuration ###
export PGADMINUSER=${PGADMINUSER}
export PGUSER=${PGUSER}
export PGHOST=${PGHOST}
export PGPORT=${CONF_PGPORT}
export PGDATABASE=${PGDATABASE}
PARSED_DATA_TABLE=psf_files

PARSED_DB_ENABLED=1
PGQRY="${PGBIN}/psql -AtX -U \${PGUSER} -h \${PGHOST} -p \${PGPORT} -d \${PGDATABASE} -c "
PGOUT="${PGBIN}/psql -AtXq -U \${PGUSER} -h \${PGHOST} -p \${PGPORT} -d \${PGDATABASE} -f "

# Uses a YYYYMMDD, adding seconds might be helpful.
WORKDATE=\$(date +"%Y%m%d")
WORKSEC=\$(date +"%s")

# Find files that are:
NOT_NEWER_THAN=\$(date --date  '-1 min' +"%H:%M:%S")

PARSED_SQL_OUT=$(pwd)/temp_sql/${PARSED_DATA_TABLE}-data-\${WORKSEC}.sql

MP3_EXT=mp3


_EOF_

}

get_port_conf
get_pg_user
get_pg_database

check_setup_ini

echo "
**** Detected Postgres, Setup psf_settings.ini ****
**** PLEASE CHECK OUR WORK! ****

If Everything looks good, Setup a cron to run $(pwd)/psf.sh

"
exit

#!/bin/bash

CSV_FILE=$1

# return the first row of the CSV
COLS=`head -1  ${CSV_FILE} | cut -d ',' -f1-1000`

# read the list of columns and create an array
IFS=',' read -a array <<< ${COLS,,}

# get the length
len="${#array[@]}"

# just holds length minus 1.
min=$(($len-1))

# Counter starts at 0.
i=0

cat << EOF >> table.sql
CREATE TABLE test (
EOF

while [ ${i} -lt ${len} ];
do
val=${array[${i}]}

# If at the last val, semicolon close.
if [ ${i} == ${min} ]; then
cat << EOF >> table.sql
${array[${i}]} text);
EOF

# Handle some specific column data types
elif [[ "$val" =~ .*"_date".* ]]; then
cat << EOF >> table.sql
${array[${i}]} date,
EOF

elif [[ "$val" =~ .*"_amount".* ]]; then
cat << EOF >> table.sql
${array[${i}]} numeric,
EOF

# I guess this could be an integer
elif [[ "$val" =~ .*"_year".* ]]; then
cat << EOF >> table.sql
${array[${i}]} numeric,
EOF

else

# default is 'text' in this example.
cat << EOF >> table.sql
${array[${i}]} text,
EOF

fi

# on to the next value in the array
let i++

done

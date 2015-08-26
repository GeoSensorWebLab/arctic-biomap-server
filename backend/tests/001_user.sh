#!/bin/sh
set -e

HH="Content-Type: application/json"
URL="http://127.0.0.1:8081/biomap/users"

tmpfile=$(mktemp -t test)

echo "TEST: Get All Users (Should Fail with Invalid Parameters)"
cat > $tmpfile << _EOF_
{
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

echo "TEST: Get All Users (Array)"
cat > $tmpfile << _EOF_
{
	"email": "*"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

echo "TEST: Get User by Email (Single)"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

echo "TEST: Create User by JSON"
cat > $tmpfile << _EOF_
{
	"email": "$RANDOM@example.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_

output=$(curl -s -H "$HH" -X POST --data @$tmpfile "$URL")
echo $output | tee $tmpfile
USER_ID=$(jq .user_id $tmpfile)

echo "TEST: Update User by JSON"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID,
	"email": "xxx$RANDOM@example.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_
echo $(curl -s -H "$HH" -X PUT --data @$tmpfile "$URL")

echo "TEST: Delete User by JSON"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID
}
_EOF_
echo $(curl -s -H "$HH" -X DELETE --data @$tmpfile "$URL")

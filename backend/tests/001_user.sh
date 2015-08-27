#!/bin/sh
set -e

HH="Content-Type: application/json"
URL="http://127.0.0.1:8081/biomap/users"

tmpfile=$(mktemp -t test)

function t {
	echo ""
	echo -e "\033[0;32mTEST: $@\033[0m"
}

t "Get All Users (Should Fail with Invalid Parameters)"
cat > $tmpfile << _EOF_
{
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Get All Users (Array)"
cat > $tmpfile << _EOF_
{
	"email": "*"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Get User by Email (Single)"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Create User by JSON"
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

t "Update User by JSON"
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

t "Delete User by JSON"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID
}
_EOF_
echo $(curl -s -H "$HH" -X DELETE --data @$tmpfile "$URL")

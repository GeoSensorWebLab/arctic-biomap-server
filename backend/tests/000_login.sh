#!/bin/sh
set -e

HH="Content-Type: application/json"
URL="http://127.0.0.1:8081/biomap/users"

tmpfile=$(mktemp -t test)
jq=./jq

echo "TEST: Create User"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_

echo $(curl -s -H "$HH" -X POST --data @$tmpfile "$URL")


URL="http://127.0.0.1:8081/biomap/login"

echo "TEST: Login User, Bad Password"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "nosecret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")


echo "TEST: Login Unknown User"
cat > $tmpfile << _EOF_
{
	"email": "ssss@gmail.com",
	"passwd": "nosecret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")


echo "TEST: Login Known User"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

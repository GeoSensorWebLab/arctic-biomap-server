#!/bin/sh
set -e

HH="Content-Type: application/json"
URL="http://127.0.0.1:8081/biomap/users"

tmpfile=$(mktemp -t test)

function t {
	echo ""
	echo -e "\033[0;32mTEST: $@\033[0m"
}

# Begin Tests

t "Create User"
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

t "Login User, Bad Password"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "nosecret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")


t "Login Unknown User"
cat > $tmpfile << _EOF_
{
	"email": "ssss@gmail.com",
	"passwd": "nosecret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")


t "Login Known User"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

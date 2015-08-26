#!/bin/sh

HH="Content-Type: application/json"
URL="http://127.0.0.1:8080/biomap/users"


cat > /tmp/input.json << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_

USER_ID=$(curl -s -H "$HH" -X POST --data @/tmp/input.json "$URL" | jq ".user_id")
echo "Created USER_ID = $USER_ID"


URL="http://127.0.0.1:8080/biomap/login"

cat > /tmp/input.json << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "nosecret"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"email": "ssss@gmail.com",
	"passwd": "nosecret"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .

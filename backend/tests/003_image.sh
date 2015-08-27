#!/bin/sh
set -e

HH="Content-Type: application/json"
BASE="http://127.0.0.1:8081/biomap"
ENDPOINT="/images"
URL="${BASE}${ENDPOINT}"

tmpfile=$(mktemp -t test)

function t {
	echo ""
	echo -e "\033[0;32mTEST: $@\033[0m"
}

# Create User for Tests
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

output=$(curl -s -H "$HH" -X POST --data @$tmpfile "$BASE/users")
echo $output > $tmpfile
USER_ID=$(jq .user_id $tmpfile)

# Create Sighting for Tests
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID,
	"animal_name": "caribou",
	"no_of_adults": 2,
	"no_of_calves": 1,
	"unusual_observations": "N/A",
	"lat": 100.0,
	"lon": 200.0,
	"visible_signs": ["A", "B", "C"],
	"photos": null
}
_EOF_
output=$(curl -s -H "$HH" -X POST --data @$tmpfile "$BASE/sightings")
echo $output > $tmpfile
SIGHTING_ID=$(jq .sighting_id $tmpfile)

# Begin Tests

t "Get All Images (Invalid Parameters)"
cat > $tmpfile << _EOF_
{
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Get All Images for a Sighting"
cat > $tmpfile << _EOF_
{
	"sighting_id": $SIGHTING_ID,
	"image_id": "*"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Upload Image for a Sighting (Incomplete)"
cat > $tmpfile << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
#IMAGE_ID=$(curl -s -H "$HH" -X POST --data @$tmpfile -F "image_file=@./image.png" "$URL")
#echo "Created IMAGE_ID = $IMAGE_ID"

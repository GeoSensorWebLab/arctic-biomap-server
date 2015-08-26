#!/bin/sh

HH="Content-Type: application/json"
URL="http://127.0.0.1:8080/biomap/sightings"
USER_ID="$1"

cat > /tmp/input.json << _EOF_
{
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"user_id": "*",
	"sighting_id": "*"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .



cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "*"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .

exit

cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"no_of_adults": 2,
	"no_of_calves": 1,
	"unusual_observations": "N/A",
	"lat": 100.0,
	"lon": 200.0,
	"vsigns": ["A", "B", "C"]
}
_EOF_

SIGHTING_ID=$(curl -s -H "$HH" -X POST --data @/tmp/input.json "$URL" | jq ".sighting_id")
echo "Created SIGHTING_ID = $SIGHTING_ID"



cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .



cat > /tmp/input.json << _EOF_
{
	"sighting_id": "$SIGHTING_ID",
	"user_id": "$USER_ID",
	"no_of_adults": 1,
	"no_of_calves": 1,
	"unusual_observations": "N/A",
	"lat": 10.0,
	"lon": 20.0,
	"vsigns": ["A", "B", "C", "D"]	
}
_EOF_
curl -s -H "$HH" -X PUT --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .



cat > /tmp/input.json << _EOF_
{
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
curl -s -H "$HH" -X DELETE --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .

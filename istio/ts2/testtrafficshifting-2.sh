while sleep 0.1; 
  do 
    curl -s -X POST $1/processor/calculate?verbosity=1 -H 'Content-Type: application/json' -d '{
      "x1": "2 + 3 + 4",
      "x2": "3 - 2"
    }' | jq '.results[] | "version=\(.version) expr=\(.expr) result=\(.result) "'
  done ;
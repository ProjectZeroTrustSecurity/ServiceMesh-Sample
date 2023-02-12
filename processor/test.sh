while sleep 0.1; 
  do 
    curl -s -X POST http://$1/processor/calculate?verbosity=1 -H 'Content-Type: application/json' -d '{
      "x1": "2 + 3 + 4",
      "x2": "3 - 2",
      "x3": "3 * 2",
      "x4": "4 / 2",
      "x5": "1 + 2 + 3 + 4 + 33 - 6 - 7 * 3 + 12 / 4",
      "x6": "12 / 4 / 3"
    }' | jq '.results[] | "version=\(.version) expr=\(.expr) result=\(.result) "'
  done ;

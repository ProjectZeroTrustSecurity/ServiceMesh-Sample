oc exec -it $1 -n $2 -c debug-container -- curl -X POST http://processor:8080/processor/calculate?verbosity=1 -H 'Content-Type: application/json' -d '{ "x1": "2 + 3" }'



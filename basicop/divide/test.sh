while sleep 0.1; 
  do 
    curl "http://$1/basicop/divide?n1=36&n2=4"
    echo ""; 
  done ;

package main 
import (
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strconv"
)

func multiply(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()

	u, _ := url.Parse(r.URL.String())
	queryParams := u.Query()

	n1, err := strconv.Atoi(queryParams.Get("n1"))
	if err != nil {
		n1 = 1
	}

	n2, err := strconv.Atoi(queryParams.Get("n2"))
	if err != nil {
		n2 = 1
	}

	result := n1 * n2
	fmt.Fprintf(w, strconv.Itoa(result))
}

func main() {
	http.HandleFunc("/basicop/multiply", multiply)
	err := http.ListenAndServe(":8080", nil)

	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

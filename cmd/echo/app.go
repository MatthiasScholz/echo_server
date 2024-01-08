package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/rs/cors"
)

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func main() {
	port := ":" + getEnv("APP_PORT", "80")
	fmt.Println("Starting server at port", port)

	mux := http.NewServeMux()
	mux.HandleFunc("/", HelloServer)
	mux.HandleFunc("/favicon.ico", FaviconHandler)

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"POST", "GET", "OPTIONS"},
		AllowedHeaders: []string{"Accept", "Content-Type", "Content-Length", "Accept-Encoding", "X-CSRF-Token", "Authorization"},
		Debug: true,
	})
	handler := c.Handler(mux)
	http.ListenAndServe(port, handler)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	url_path := r.URL.Path[1:]
	url := r.URL
	query := r.Form
	header := r.Header
	bodyBytes, _ := ioutil.ReadAll(r.Body)
	body := string(bodyBytes)
	redirect := r.Response
	requestURI := r.RequestURI

	fmt.Println("Someone opened:", url_path)
	fmt.Println("URL:", url)
	fmt.Println("Query parameters:", query)
	fmt.Println("Header:", header)
	fmt.Println("Body:", body)
	fmt.Println("Redirect Response:", redirect)
	fmt.Println("Request URI:", requestURI)

	// Response
	fmt.Fprintf(w, "Hello, %s!", url_path)
}

func FaviconHandler(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "favicon.ico")
}

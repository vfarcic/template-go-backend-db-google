package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.New()
	router.GET("/", rootHandler)
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}
	router.Run(fmt.Sprintf(":%s", port))
	log.Println("This is silly. Convert it into something great!")
}

func rootHandler(ctx *gin.Context) {
	output := "This is a silly demo"
	ctx.String(http.StatusOK, output)
}

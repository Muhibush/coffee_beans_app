package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/coffee-beans-app/scraper/internal/extractor"
)

func main() {
	ext := &extractor.TokopediaExtractor{}
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	storeURL := "https://www.tokopedia.com/fugolcoffee/product"
	products, err := ext.ExtractURLs(ctx, storeURL, 5)
	if err != nil {
		log.Fatalf("Extraction failed: %v", err)
	}

	fmt.Printf("Successfully extracted %d products:\n", len(products))
	for _, p := range products {
		fmt.Printf("- [%s] (%s)\n", p.Title, p.URL)
	}
}

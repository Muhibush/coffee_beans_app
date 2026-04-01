package browser

import (
	"context"
	"log"
	"sync"
	"time"

	"github.com/go-rod/rod"
	"github.com/go-rod/rod/lib/launcher"
	"github.com/go-rod/stealth"
)

var (
	instance *Browser
	once     sync.Once
)

// Browser wraps the go-rod browser with stealth configuration.
type Browser struct {
	mu      sync.Mutex
	browser *rod.Browser
	timeout time.Duration
}

// DefaultTimeout is the default page load timeout.
const DefaultTimeout = 30 * time.Second

// Get returns the singleton Browser instance.
func Get() *Browser {
	once.Do(func() {
		instance = &Browser{
			timeout: DefaultTimeout,
		}
	})
	return instance
}

// ensureBrowser lazily initializes the underlying rod.Browser.
func (b *Browser) ensureBrowser() (*rod.Browser, error) {
	b.mu.Lock()
	defer b.mu.Unlock()

	if b.browser != nil {
		return b.browser, nil
	}

	// Launch Chrome with stealth-friendly flags
	u, err := launcher.New().
		Headless(true).
		Set("disable-blink-features", "AutomationControlled").
		Set("disable-features", "IsolateOrigins,site-per-process").
		Set("no-first-run").
		Set("no-default-browser-check").
		Set("disable-default-apps").
		Launch()
	if err != nil {
		return nil, err
	}

	browser := rod.New().ControlURL(u)
	if err := browser.Connect(); err != nil {
		return nil, err
	}

	b.browser = browser
	log.Println("[browser] Chrome browser initialized")
	return b.browser, nil
}

// NewStealthPage creates a new stealth page with the configured timeout.
func (b *Browser) NewStealthPage() (*rod.Page, error) {
	browser, err := b.ensureBrowser()
	if err != nil {
		return nil, err
	}

	page, err := stealth.Page(browser)
	if err != nil {
		return nil, err
	}

	page = page.Timeout(b.timeout)
	return page, nil
}

// NavigateWithStealth opens a URL in a new stealth page, waits for load, and returns the page.
func (b *Browser) NavigateWithStealth(ctx context.Context, url string) (*rod.Page, error) {
	page, err := b.NewStealthPage()
	if err != nil {
		return nil, err
	}

	// Apply context timeout if present
	if deadline, ok := ctx.Deadline(); ok {
		remaining := time.Until(deadline)
		if remaining > 0 {
			page = page.Timeout(remaining)
		}
	}

	// Navigate to the URL
	if err := page.Navigate(url); err != nil {
		page.MustClose()
		return nil, err
	}

	// Wait for the page to finish loading
	if err := page.WaitLoad(); err != nil {
		page.MustClose()
		return nil, err
	}

	// Small delay for dynamic content
	time.Sleep(2 * time.Second)

	return page, nil
}

// Close shuts down the browser instance.
func (b *Browser) Close() {
	b.mu.Lock()
	defer b.mu.Unlock()

	if b.browser != nil {
		if err := b.browser.Close(); err != nil {
			log.Printf("[browser] Error closing browser: %v", err)
		}
		b.browser = nil
		log.Println("[browser] Chrome browser closed")
	}
}

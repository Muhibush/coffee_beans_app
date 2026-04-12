package browser

import (
	"context"
	"log"
	"sync"
	"time"

	"github.com/go-rod/rod"
	"github.com/go-rod/rod/lib/launcher"
	"github.com/go-rod/rod/lib/proto"
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
const DefaultTimeout = 2 * time.Minute

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
		// Check if the browser is still responsive
		_, err := b.browser.Version()
		if err == nil {
			return b.browser, nil
		}
		log.Printf("[browser] Stale browser detected: %v. Re-initializing...", err)
		b.browser = nil
	}

	// Launch Chrome with stealth-friendly flags
	u, err := launcher.New().
		Headless(true).
		Set("disable-blink-features", "AutomationControlled").
		Set("disable-features", "IsolateOrigins,site-per-process").
		Set("no-first-run").
		Set("no-default-browser-check").
		Set("disable-default-apps").
		Set("window-size", "1920,1080").
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

	scale := 1.0
	// Set desktop viewport with DPR=1 to ensure consistent rendering
	if err := page.SetViewport(&proto.EmulationSetDeviceMetricsOverride{
		Width:             1920,
		Height:            1080,
		DeviceScaleFactor: 1,
		Scale:             &scale,
		Mobile:            false,
	}); err != nil {
		page.Close()
		return nil, err
	}

	// Set a real Desktop User Agent to further trick Tokopedia into serving the full grid
	if err := page.SetUserAgent(&proto.NetworkSetUserAgentOverride{
		UserAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
	}); err != nil {
		page.Close()
		return nil, err
	}

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
		page.Close()
		return nil, err
	}

	// Wait for the page to finish loading
	if err := page.WaitLoad(); err != nil {
		page.Close()
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

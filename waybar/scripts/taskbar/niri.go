package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// Customize your icons here based on the app_id (use Nerd Fonts)
var icons = map[string]string{
	"zen":                   "󰈹",
	"com.mitchellh.ghostty": "",
	"kitty":                 "",
	"discord":               "",
	"spotify":               "",
	"code":                  "󰨞",
	"default":               "",
}

type Window struct {
	AppID     string `json:"app_id"`
	Title     string `json:"title"`
	IsFocused bool   `json:"is_focused"`
}

type WaybarOutput struct {
	Text    string `json:"text"`
	Tooltip string `json:"tooltip"`
	Class   string `json:"class"`
}

func getWindows() []Window {
	cmd := exec.Command("niri", "msg", "-j", "windows")
	out, err := cmd.Output()
	if err != nil {
		return nil
	}

	var windows []Window
	if err := json.Unmarshal(out, &windows); err != nil {
		return nil
	}
	return windows
}

func update() {
	windows := getWindows()
	var textParts []string
	var tooltipParts []string

	for _, w := range windows {
		// Normalize app_id
		appID := strings.ToLower(w.AppID)
		if appID == "" {
			appID = "default"
		}

		// Fetch icon
		icon, exists := icons[appID]
		if !exists {
			icon = icons["default"]
		}

		// Shorten long titles
		title := w.Title
		if len(title) > 20 {
			title = title[:17] + "..."
		}

		tooltipParts = append(tooltipParts, w.Title)

		// Apply Pango markup (Stealth Minimal, Icons ONLY)
		var span string
		if w.IsFocused {
			// Soft off-white to match your Waybar text color
			span = fmt.Sprintf("<span font_weight='bold' foreground='#e0e0e0'> %s </span>", icon)
		} else {
			// Dim gray for unfocused windows
			span = fmt.Sprintf("<span foreground='#666666'> %s </span>", icon)
		}

		textParts = append(textParts, span)
	}

	output := WaybarOutput{
		Text:    strings.Join(textParts, ""),
		Tooltip: "Niri Taskbar\n" + strings.Join(tooltipParts, "\n"),
		Class:   "niri-taskbar",
	}

	// Waybar expects a single line of JSON
	jsonOutput, err := json.Marshal(output)
	if err == nil {
		fmt.Println(string(jsonOutput))
	}
}

func main() {
	// Print initial state on startup
	update()

	// Listen to the Niri event stream
	cmd := exec.Command("niri", "msg", "-j", "event-stream")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating stdout pipe: %v\n", err)
		os.Exit(1)
	}

	if err := cmd.Start(); err != nil {
		fmt.Fprintf(os.Stderr, "Error starting niri event-stream: %v\n", err)
		os.Exit(1)
	}

	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		line := scanner.Text()

		var event map[string]interface{}
		if err := json.Unmarshal([]byte(line), &event); err != nil {
			continue
		}

		// Only update if the event alters window states
		updateNeeded := false
		for key := range event {
			// Catch any event related to windows (WindowOpenedOrChanged, WindowClosed, etc.)
			if strings.Contains(key, "Window") {
				updateNeeded = true
				break
			}
		}

		if updateNeeded {
			update()
		}
	}
}

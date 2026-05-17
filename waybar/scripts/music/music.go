package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"html"
	"math/rand"
	"os"
	"os/exec"
	"strings"
	"time"
)

const quoteFile = "/tmp/waybar_quote"

var quotes = []string{
	"No zero days.", "Build. Learn. Repeat.", "Stay hard.",
	"One bug at a time.", "Finish what you started.", "Discipline > Motivation.",
	"Amor Fati.", "The obstacle is the way.", "Embody your philosophy.",
	"Waste no more time.", "Master yourself.", "Maktub.",
	"Realize your destiny.", "Fall seven, stand eight.", "Focus on the present.",
	"Inherited Will.", "Take risks, create a future.", "Keep walking forward.",
	"Stand and fight.", "Discipline = Freedom.", "Dreams need work.",
	"Discipline > Regret.", "No high-level magic.", "Build from scratch.",
	"Trust the process.", "Focus and execute.", "Seek discomfort.",
	"Outwork your doubts.", "Fortune favors the bold.", "Action > Perfection.",
	"Embrace the grind.", "Consistency is key.", "Compile and conquer.",
	"Master your tools.", "Drums of liberation.",
	"One step a day.",
}

// WaybarOutput represents the JSON structure Waybar expects
type WaybarOutput struct {
	Text    string `json:"text"`
	Tooltip string `json:"tooltip"`
	Class   string `json:"class"`
}

func main() {
	// Seed random generator
	rand.Seed(time.Now().UnixNano())

	player := getPriorityPlayer()

	if player != "" {
		status := runCmd("playerctl", "--player="+player, "status")

		if status == "Playing" || status == "Paused" {
			icon := getIcon(player)
			title := html.EscapeString(runCmd("playerctl", "--player="+player, "metadata", "--format", "{{ title }}"))
			artist := html.EscapeString(runCmd("playerctl", "--player="+player, "metadata", "--format", "{{ artist }}"))

			stateIcon := "" // Playing
			class := "playing"
			if status == "Paused" {
				stateIcon = ""
				class = "paused"
			}

			// Format the visible text
			text := fmt.Sprintf("%s %s %s", icon, stateIcon, title)

			// Format the tooltip (shown on hover)
			tooltip := title
			if artist != "" {
				tooltip = fmt.Sprintf("%s\nby %s", artist, title)
			}

			printJson(text, tooltip, class)
			return
		}
	}

	// Fallback to quote if no player is active or playing/paused
	showQuote()
}

// getPriorityPlayer uses a two-pass system to find the best player
func getPriorityPlayer() string {
	out := runCmd("playerctl", "-l")
	if out == "" {
		return ""
	}

	players := strings.Split(out, "\n")

	// Pass 1: Absolute priority to whatever is currently making noise
	for _, p := range players {
		if p == "" {
			continue
		}
		status := runCmd("playerctl", "--player="+p, "status")
		if status == "Playing" {
			return p
		}
	}

	// Pass 2: Everything is paused. Fall back to the hierarchy.
	priorities := []string{"spotify", "mpv", "firefox", "chromium", "vlc"}

	for _, priority := range priorities {
		for _, availablePlayer := range players {
			if strings.Contains(availablePlayer, priority) {
				return availablePlayer
			}
		}
	}

	// Pass 3: Ultimate fallback to whatever playerctl found first
	if len(players) > 0 && players[0] != "" {
		return players[0]
	}

	return ""
}

func getIcon(player string) string {
	player = strings.ToLower(player)
	switch {
	case strings.Contains(player, "spotify"):
		return ""
	case strings.Contains(player, "firefox"):
		return ""
	case strings.Contains(player, "chromium"):
		return ""
	case strings.Contains(player, "mpv"):
		return ""
	case strings.Contains(player, "vlc"):
		return "󰕼"
	default:
		return "" // Generic music note
	}
}

func showQuote() {
	var currentQuote string

	info, err := os.Stat(quoteFile)
	// If file doesn't exist or is older than 60 seconds
	if os.IsNotExist(err) || time.Since(info.ModTime()).Seconds() > 60 {
		currentQuote = quotes[rand.Intn(len(quotes))]
		os.WriteFile(quoteFile, []byte(currentQuote), 0644)
	} else {
		// Read existing quote
		data, _ := os.ReadFile(quoteFile)
		currentQuote = strings.TrimSpace(string(data))
		// Fallback if file was empty
		if currentQuote == "" {
			currentQuote = quotes[rand.Intn(len(quotes))]
		}
	}

	text := fmt.Sprintf("󰝛 %s", currentQuote)
	printJson(text, "Stay focused.", "quote")
}

// Helper to run commands and return stdout as a trimmed string
func runCmd(name string, args ...string) string {
	cmd := exec.Command(name, args...)
	var out bytes.Buffer
	cmd.Stdout = &out
	err := cmd.Run()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(out.String())
}

// Helper to print the JSON output
func printJson(text, tooltip, class string) {
	output := WaybarOutput{
		Text:    text,
		Tooltip: tooltip,
		Class:   class,
	}
	jsonData, _ := json.Marshal(output)
	fmt.Println(string(jsonData))
}

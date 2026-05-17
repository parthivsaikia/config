#!/bin/bash

QUOTE_FILE="/tmp/waybar_quote"

quotes=(
    "No zero days."
    "Build. Learn. Repeat."
    "Stay hard."
    "One bug at a time."
    "Finish what you started."
    "Discipline > Motivation."
    "Amor Fati."
    "The obstacle is the way."
    "Embody your philosophy."
    "Waste no more time."
    "Master yourself."
    "Maktub."
    "Realize your destiny."
    "Fall seven, stand eight."
    "Focus on the present."
    "Inherited Will."
    "Take risks, create a future."
    "Keep walking forward."
    "Stand and fight."
    "Discipline = Freedom."
    "Dreams need work."
    "Discipline > Regret."
    "No high-level magic."
    "Build from scratch."
    "Trust the process."
    "Focus and execute."
    "Seek discomfort."
    "Outwork your doubts."
    "Fortune favors the bold."
    "Action > Perfection."
    "Embrace the grind."
    "Consistency is key."
    "Compile and conquer."
    "Master your tools."
    "Drums of liberation."
)

# Find available player in priority order
player=$(playerctl -l 2>/dev/null | grep -E 'spotify|firefox|chromium|mpv|vlc' | head -n 1)

# Escape special chars for Waybar/Pango
escape_text() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Show cached quote (changes every 60s)
show_quote() {
    if [ ! -f "$QUOTE_FILE" ] || [ $(( $(date +%s) - $(stat -c %Y "$QUOTE_FILE") )) -gt 60 ]; then
        echo "${quotes[$RANDOM % ${#quotes[@]}]}" > "$QUOTE_FILE"
    fi
    echo "󰝛 $(cat "$QUOTE_FILE")"
}

# Choose icon based on player
get_icon() {
    case "$player" in
        *spotify*) echo "" ;;
        *firefox*) echo "" ;;
        *chromium*) echo "" ;;
        *mpv*) echo "" ;;
        *vlc*) echo "󰕼" ;;
        *) echo "" ;;
    esac
}

if [ -n "$player" ]; then
    status=$(playerctl --player="$player" status 2>/dev/null)
    icon=$(get_icon)

    if [ "$status" = "Playing" ]; then
        title=$(playerctl --player="$player" metadata --format "{{ title }}" 2>/dev/null | escape_text)
        echo "$icon  $title"
    elif [ "$status" = "Paused" ]; then
        title=$(playerctl --player="$player" metadata --format "{{ title }}" 2>/dev/null | escape_text)
        echo "$icon  $title"
    else
        show_quote
    fi
else
    show_quote
fi

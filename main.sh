#!/usr/bin/env bash
cleanup() {
    kill $LISTENER_PID $WATCHER_PID && echo CLEAN || echo DIRTY
}
trap cleanup EXIT



IP="192.168.1.20"
PORT="7878"
STATUS=""

# Listener
nc -lk -p "$PORT" > /tmp/incoming & 
LISTENER_PID=$!

# Incoming Message Watcher
watcher() {
    while true; do
        watch --chgexit -n 0.5 "cat /tmp/incoming" > /dev/null && \
        { echo -e \\033[$(( $(tput lines)-2 ))\;1H; \
        cat /tmp/incoming; \
        echo -e \\033[$(tput lines)\;1H; }
    done
}
watcher &
WATCHER_PID=$!

while true; do
    # Move cursor to bottom of screen
    echo -e \\033[$(tput lines)\;5H

    read -erp "$STATUS > " MSG
    echo $MSG | nc "$IP" "$PORT" -w 1
    STATUS=$?

    #echo -e \\033[$(( $(tput lines)-2 ))\;1H
    #cat /tmp/incoming
done


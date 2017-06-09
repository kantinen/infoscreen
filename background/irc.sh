#!/bin/bash

# Copyright © 2014-2015 Infoskærms-gruppen <infoskaerm@dikumail.dk>
#
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING file for more details.

irc_out=$HOME/diku_irc_out
breaking_news=$HOME/breaking_news

timecolor='\e[0;31m'
usercolor='\e[0;32m'
msgcolor='\e[0;37m'
name=infoskaerm

color_usermsg() {
    # Første linje af fmt-uddataen.
    read line
    time=$(echo "$line" | cut -d ' ' -f 1)
    user=$(echo "$line" | cut -d ' ' -f 2- | cut -d '>' -f 1)
    end=$(echo "$line" | cut -d '>' -f 2-)
    {
        echo -en "$timecolor"
        echo -en "$time "
        echo -en "$usercolor"
        echo -n "$user>"
        echo -en "$msgcolor"
        echo "$end"
    }

    cat # Resterende linjer.
}

# Input til IRC-klienten.
in=$(mktemp)
touch $in

channel="#diku"

join_channel() {
    # Join #diku.
    (echo ":j $channel" > $in) &
}

ircloop() {
    while true; do
        sic -h irc.freenode.net -n $name
        sleep 2
        join_channel
    done
}

goto_slide() {
    echo "goto $1" | $HOME/kantinfo/kantinfo-order.py
}

set_breaking_news() {
    news=$1
    echo "$news" > $breaking_news
    goto_slide breaking_news.sh
}

process_line() {
    line=$1
    if echo "$line" | egrep -q '<[^>]+> '$name'[:,] hjælp'; then
        echo "Jeg forstår følgende kommandoer:"
        echo "  breaking: <besked>"
        echo "  vis IRC"
    elif echo "$line" | egrep -q '<[^>]+> '$name'[:,] breaking: '; then
        news=$(echo "$line" | sed 's/.*breaking: //')
        set_breaking_news "$news"
        echo "Ryd forsiden!  $news"
    elif echo "$line" | egrep -qi '<[^>]+> '$name'[:,] vis irc'; then
        echo "Jeps, nu kan alle følge med i samtalen!"
        goto_slide irc.terminal
    fi
}

join_channel

# Kør klienten i baggrunden.
touch $irc_out
tail -f $in \
    | ircloop \
    | grep --line-buffered -E "^$channel" \
    | gawk '{$1=$2=$3=""; print; fflush();}' \
    | tee /dev/stderr \
    | while IFS='' read line; do
    process_line "$line" >> "$in"
    echo "$line" | fmt -75 -s | color_usermsg >> $irc_out
done

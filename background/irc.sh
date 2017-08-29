#!/bin/bash

# Copyright © 2014-2017 Infoskærms-gruppen <infoskaerm@dikumail.dk>
#
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING file for more details.

if [ "$1" = 'debug' ]; then
    IS_DEBUG=1
fi

irc_out=$HOME/diku_irc_out
breaking_news=$HOME/breaking_news

timecolor='\e[0;31m'
usercolor='\e[0;32m'
msgcolor='\e[0;37m'
name=infoskaerm
channel="#diku"

# Input to the IRC client loop.
in=$(mktemp)
touch $in

# Output text file read by the slide.
touch $irc_out


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

per_line() {
    function=$1
    while IFS='' read -r line; do
        echo -e "$line" | $function
    done
}

deirc() {
    # Convert IRC colors to terminal colors.
    # "$(dirname "$0")/deirc.pl"
    # Disabled, because I suspect it is broken.
    cat
}

color_usermsg() {
    # The first line of the 'fmt' output.
    IFS='' read -r line

    time=$(echo -e "$line" | cut -d ' ' -f 1)
    user=$(echo -e "$line" | cut -d ' ' -f 2- | cut -d '>' -f 1)
    end=$(echo -e "$line" | cut -d '>' -f 2- | deirc)
    {
        echo -en "$timecolor"
        echo -en "$time "
        echo -en "$usercolor"
        echo -en "$user>"
        echo -en "$msgcolor"
        echo -e "$end"
    }

    # Any remaining lines.
    cat | deirc
}

shorten_line() {
    # Keep only the most important parts.
    cut -d ':' -f 2- \
        | cut -d ' ' -f 3-
}

print_line() {
    fmt -75 -s \
        | color_usermsg \
        | tee /dev/stderr
}

handle_line() {
    IFS='' read -r line
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

process_text() {
    grep --line-buffered -E "^$channel" \
        | per_line shorten_line \
        | tee >(per_line print_line >> $irc_out) \
              >(per_line handle_line >> $in) \
              > /dev/null
}

if [ "$IS_DEBUG" ]; then
    # Få inddatalinjerne til at ligne at de er fra IRC, processér dem,
    # og vis dem.
    fake_irc() {
        echo -e "#diku       : 01/01/01 00:00 <concieggs> $(cat)"
    }
    per_line fake_irc \
        | process_text
else
    # Log på IRC og kør klienten uendeligt.
    join_channel
    tail -f $in \
        | while true; do ircloop; done \
        | while true; do process_text; done
fi

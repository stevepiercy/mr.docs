#!/bin/bash
set -e

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
#COL_MAGENTA=$ESC_SEQ"35;01m"
#COL_CYAN=$ESC_SEQ"36;01m"


## Functions we use
# Error

function error_exit {
	echo -en "$COL_RED$1$COL_RESET" 1>&2
	exit 1
}

#####
ask() {
    # http://djm.me/ask
    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -en "$COL_BLUE$1$COL_RESET [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}
## Example
# Default to No if the user presses enter without giving an answer:
#if ask "Do you want to do such-and-such?" N; then
#    echo "Yes"
#else
#    echo "No"
#fi


####
# Vars
YEAR=$(date +"%Y")

# Use "-d" to skip questions and just use the defaults
while getopts ":d" opt; do
    case "$opt" in
	d)
	    echo -en "$COL_BLUE Using default settings$COL_RESET"
	    exit 0
	;;
    esac
done


# Start running checks, like do we have already d conf.py in docs and so on
echo -en "$COL_YELLOW Running checks ...$COL_RESET\n"

# If we have no .jekyll we will create one
echo -en "$COL_YELLOW Do we have a .jekyll already? ...$COL_RESET\n"
if [ -f "docs/.jekyll" ]; then
	echo -en "$COL_YELLOW Found one moving on ...$COL_RESET\n"
	: # do nothing and move on
else
	echo -en "$COL_YELLOW Creating .jekyll ...$COL_RESET\n"
	touch docs/.jekyll
fi

# Check if we have already a index.rst if not create one
echo -en "$COL_YELLOW Checking for a index.rst ...$COL_RESET\n"
if [ -f "docs/index.rst" ]; then
	echo -en "$COL_YELLOW Found index, moving on ...$COL_RESET\n"
	: # Do nothing
	#cp ../templates/index.ini docs/index.rst
else
	echo -en "$COL_YELLOW Creating example index ...$COL_RESET\n"
	cp templates/index.ini docs/index.rst
fi

# Check if we have already a config, file, if so tell
if [ -f docs/conf.py ]; then
    	if ask "Do you want to override?" N; then
		rm docs/conf.py
	else
		echo -en "$COL_RED You decided not to override, finishing up...$COL_RESET\n"
		exit 0
	fi
else
    echo -en "$COL_YELLOW Looking good, lets continue$COL_RESET\n"
fi


# Start the questions
# Ask for the name of the project
echo
echo -en "$COL_GREEN Name of the project:$COL_RESET"
read project_name
project=$project_name
: "${project:="ExampleDocs"}"

# Ask for the name of the author
echo -en "$COL_GREEN Name of the author:$COL_RESET"
read project_author
author=$project_author
: "${author:="SomePerson"}"

# Ask for the version, like 1.0
echo -en "$COL_GREEN This is version:$COL_RESET"
read project_version
version=$project_version
: "${version:="1.0"}"

# Ask for the html title
echo -en "$COL_GREEN Please enter a title for html:$COL_RESET"
read project_html_title
project_title=$project_html_title
: "${project_title="My long html title"}"

# Ask for the short title
echo -en "$COL_GREEN Please enter a short title for html:$COL_RESET"
read project_html_short_title
project_title_short=$project_html_short_title
: "${project_title_short="My short title"}"

# Copy the template over
cp templates/conf.py.ini docs/conf.py

# Run sed to replace the place holder
sed -i "s/template_project_name/$project/g" docs/conf.py
sed -i "s/template_author/$author/g" docs/conf.py
sed -i "s/template_year/$YEAR/g" docs/conf.py
sed -i "s/template_version/$version/g" docs/conf.py
sed -i "s/template_html.title/$project_title/g" docs/conf.py
sed -i "s/template_html_short_title/$project_title_short/g" docs/conf.py

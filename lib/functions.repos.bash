function github-directory {
    echo ~/Documents/GitHub
}

# Clone a repo from GitHub into the appropriate directory.
function rclone {
    local repo=$1
    local dir="$(github-directory)/${repo}"

    mkdir -p "$(dirname $dir)"
    hub clone $repo $dir
    rcd $repo
}

# Open coverage reports in a browser.
function rcov {
    open artifacts/tests/coverage/index.html
}

function ropen {
    hub browse "$@"
}

# Change directory into a GitHub repo clone.
function rcd {
    local name=$1
    local base=$(github-directory)
    local matches=
    local count=

    if [ -z $name ]; then
        cd $base
        return
    fi

    # Explicitly named ...
    if [ -d "${base}/${name}" ]; then
        matches="${base}/${name}"
        count=1
    else
        matches=$(find $base -iname $name -depth 2)
        count=$(echo $matches | wc -w | tr -d ' ')
    fi

    if [ $count -eq 1 ]; then
        cd $matches
        repo=$(git-repo)
        if [ ! -z $repo ]; then
            echo
            echo "$(color-grey)Found $(color-magenta)${repo} $(color-grey)at $(color-blue)$(pwd)"
            echo
        fi
    elif [ $count -eq 0 ]; then
        echo
        echo "$(color-grey)Repository $(color-red)${name} $(color-grey)does not exist."
        echo
    else
        echo
        echo "$(color-grey)Found $(color-red)${count} $(color-grey)repositories matching $(color-red)${name}$(color-grey):"
        echo

        for repo in $matches; do
            echo " $(color-grey)* $(color-magenta)$(echo $repo | cut -c$(expr 2 + ${#base})-)"
        done

        echo
    fi

    color-reset
}

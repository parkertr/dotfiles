GIT_DIR_CACHE=""

# Clone a repo from GitHub into the appropriate directory.
function rclone {
    local repo=$1
    local dir="${GIT_DIR_GITHUB}/${repo}"

    mkdir -p "$(dirname $dir)"
    hub clone -p $repo $dir

    rcd-reindex
    rcd $repo
}

# Change directory into a git clone ...
function rcd {
    local name=$1

    if [ -z $name ]; then
        return
    fi

    local base=
    local matches=
    local count=

    if [[ $count == "" ]]; then
        for base in $GIT_DIR_LIST; do
            if [ -d $base ]; then
                matches=$(find $base -mindepth 2 -maxdepth 2 -iname $name)
                count=$(echo $matches | wc -w | tr -d ' ')

                if [ $count -gt 0 ]; then
                    break
                fi
            fi
        done
    fi

    if [[ $count -eq 0 ]]; then
        for base in $GIT_DIR_LIST; do
            if [ -d "${base}/${name}" ]; then
                matches="${base}/${name}"
                count=1
                break
            fi
        done
    fi

    if [[ $count == "" ]]; then
        count=0
    fi

    if [ $count -eq 1 ]; then
        cd $matches
        repo=$(git-repo)
        if [ ! -z $repo ]; then
            echo "  $(color-green)>>> $(color-magenta)$repo $(color-dark-grey)found in $(color-blue)$(pwd)"
        fi
    elif [ $count -eq 0 ]; then
        echo "  $(color-red)!!! $(color-dark-grey)Repository $(color-grey)${name} $(color-dark-grey)does not exist."
    else
        echo "  $(color-orange)??? $(color-dark-grey)Found $(color-grey)${count} $(color-dark-grey)repositories matching $(color-grey)${name}$(color-dark-grey):"
        local options=""
        for repo in $matches; do
            options="$options $(echo $repo | cut -c$(expr 2 + ${#base})-)"
        done

        color-magenta

        local PS3="$(color-reset): "
        select repo in $options; do
            if [ ! -z $repo ]; then
                cd "${base}/${repo}"
                break
            fi
        done
    fi

    color-reset

    if [ $count -eq 0 ]; then
        return 1
    fi

    return 0
}

function rcd-reindex {
    GIT_DIR_CACHE=""
    for base in $GIT_DIR_LIST; do
        if [ -d $base ]; then
            for dir in $(find $base -mindepth 2 -maxdepth 2); do
                local repo=$(echo $dir | rev | cut -d/ -f1-2 | rev)
                GIT_DIR_CACHE="$repo $(basename "$repo") $GIT_DIR_CACHE"
            done
        fi
    done
}

function rbranches {
    local user=$1

    if [ -z $user ]; then
        local depth=3
        local dir="${GIT_DIR_GITHUB}"
    else
        local depth=2
        local dir="${GIT_DIR_GITHUB}/${user}"
    fi

    local rev_type=
    local rev_name=
    local rev=

    local rev_name=
    local rev=
    local repo_dir=
    local repo=

    for repo_dir in $(find $dir -name ".git" -depth $depth); do
        pushd $repo_dir > /dev/null
        local repo=$(git-repo)

        if [ -z "$repo" ]; then
            repo=$(dirname $repo_dir)
        fi

        read rev_type rev_name rev <<< $(git-current-color)
        echo "$(color-magenta)$repo$(color-dark-grey): $rev"
        popd > /dev/null
    done
}

function __rcd-completion {
    if [[ "$GIT_DIR_CACHE" == "" ]]; then
        rcd-reindex
    fi

    COMPREPLY=( $(compgen -W "$GIT_DIR_CACHE" -- ${COMP_WORDS[COMP_CWORD]}) )
}

complete -F __rcd-completion rcd
complete -F __rcd-completion rbranches

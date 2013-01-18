#!/bin/sh

pkgname=name
pkgver=0.1
pkgdesc="Package description"
url="http://url.to/software/page"
source="http://url.to/archive/file/$pkgname-$pkgver.tar.gz
pkg2.zip::http://second.package/with/name.zip"

install(){
    cd $srcdir/$pkgname-$pkgver && \
        ./configure && \
        make && \
        make check && \
        make install || return $?
}

uninstall(){
    return 1
}

#######################################
# internal functions

#######################################
# utilities

__exit_with_mes(){
    # __exit_with_mes status message
    echo "$__script_name: $2" 1>&2
    exit $1
}

__message(){
    # __message message
    echo "$__script_name: $1" 1>&2
}

__match_string(){
    # __match_string str pattern
    echo "$1" | grep "$2" >/dev/null 2>&1
}

###################################
# run under $srcdir

__git_fetch(){
    # __git_fetch dir url
    if test -d "$2"
    then
        pushd "$2"
        git pull origin master || \
            __exit_with_mes $? "Git: pull failed: $2"
        popd
    else
        git clone --depth 1 "$2" "$1" || \
            __exit_with_mes $? "Git: clone failed: $2"
    fi
}

__extract(){
    # __extract file
    case "$1" in
        *.tar)
            tar xvf "$1" ;;
        *.tar.gz|*.tgz)
            tar xvzf "$1" ;;
        *.zip)
            unzip "$1" ;;
        *)
            __message "Did not extract Unknown file: $1" ;;
    esac
}

__download_extract(){
    # __download_extract file url
    # todo: use curl if wget is not avaliable
    wget -O "$1" "$2" || __exit_with_mes $? "Download failed: $2"
    __extract "$1" || __exit_with_mes $? "Extract failed: $1"
}

__fetch_files(){
    if test -z "$source"
    then
        __message "$No sources"
        return 0
    fi

    mkdir -p "$srcdir"
    cd "$srcdir"
    for s in $source
    do
        if __match_string "$s" "::"
        then
            file="$(echo "$s" | sed -e 's/::.*$//g')"
            url="$(echo "$s" | sed -e 's/^.*:://g')"
        else
            url="$s"
            file="$(echo "$s" | grep -o '[^/]*$')"
        fi

        if __match_string "$url" "^git://" || __match_string "$url" "\\.git$"
        then
            dir="$(echo "$file" | sed -e 's/\.git$//g')"
            __git_fetch "$dir" "$url"
        else
            if test -f "$file"
            then
                __message "$file already exists: skip download"
            else
                __download_extract "$file" "$url"
            fi
        fi
    done
}

######################################
# main functions
# called under $startdir

__install(){
    __fetch_files
    cd "$startdir"

    install "$@" || __exit_with_mes $? "Install failed"
    cd "$startdir"
    __message "Install done"
}

__show_info(){
    echo "Package: $pkgname $pkgver"
    echo "    $pkgdesc"
    echo "URL: $url"
}

__fetch(){
    __fetch_files
}

__clean(){
    # this may very dengerous
    rm -rf $srcdir
}

__uninstall(){
    uninstall"$@" || __exit_with_mes $? "Uninstall failed"
}

__help(){
    cat <<__EOC__ 1>&2
$__script_name: usage: $__script_name <command>

Commands:

    install    Install package
    info       Show info about this package
    fetch      Only fetch and extract archives
    uninstall  Uninstall package (if possible)
    help       Display this help message
    version    Display version info
__EOC__
}

__version_info(){
    echo $__script_name $__version 1>&2
}

__main(){
    cd "$startdir"
    cmd="$1"
    shift
    if test -z "$cmd"
    then
        __help
    else
        case "$cmd" in
            install)
                __install "$@" ;;
            info)
                __show_info "$@" ;;
            fetch)
                __fetch "$@" ;;
            # clean)
            #     __clean "$@" ;;
            uninstall)
                __uninstall "$@" ;;
            help|--help|-h)
                __help "$@" ;;
            version|--version|-v)
                __version_info "$@" ;;
            *)
                __message "invalid command: $cmd"
                __help "$@" ;;
        esac
    fi
}

__version=0.1

__script_name="$0"
# startdir="$(dirname "$0")"      # or just $PWD?
startdir="$PWD"
srcdir="${startdir}/src-${pkgname}"
__main "$@"

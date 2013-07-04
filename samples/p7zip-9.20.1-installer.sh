#!/bin/sh

pkgname=p7zip
pkgver=9.20.1
pkgdesc="A file archiver with highest compression ratio"
url="http://p7zip.sourceforge.net/"
source="$pkgname_$pkgver.tar.bz2::http://sourceforge.jp/frs/g_redir.php?m=jaist&f=%2Fp7zip%2F${pkgname}%2F${pkgver}%2F${pkgname}_${pkgver}_src_all.tar.bz2"

_prefix=$HOME/.local

main(){
    cd $srcdir/${pkgname}_$pkgver && \
        make 7z && \
        make test_7z && \
        sed --in-place -e "s|^DEST_HOME=/usr/local$|DEST_HOME=$_prefix|" install.sh && \
        ./install.sh
}

################################################################################
# p7zip-installer.sh --- Install p7zip

# Usage
# -----

# installer.sh <command> [<option> ...]

# Commands:

#     install  Install package.
#              May accept additional options.
#     info     Show info about this package.
#     fetch    Only fetch and extract archives.
#     help     Display this help message.
#     version  Display version info.



################################################################################
# installer.sh --- Template for installation automation script

# Auther: 10sr
# URL: https://github.com/10sr/installer_sh
# Lisence: CC0: http://creativecommons.org/publicdomain/zero/1.0/



#######################################
# Internal functions
# Do not modify below!

#######################################
# utilities

__exit_with_mes(){
    # __exit_with_mes status message
    echo "$__script_name: $2" 1>&2
    exit $1
}

__message(){
    # __message message
    # echo "$__script_name: $1" 1>&2
    echo ":: $1" 1>&2
}

__warn(){
    echo "$1" 1>&2
}

###################################
# run under $srcdir

__extract(){
    # __extract file
    __message "Start extracting $1..."
    case "$1" in
        *.tar)
            tar -xvf "$1" ;;
        *.tar.gz|*.tgz)
            tar -xvzf "$1" ;;
        *.tar.bz2|*.tbz)
            tar -xvjf "$1" ;;
        *.tar.xz|*.txz)
            tar -xvJf "$1" ;;
        *.zip)
            unzip "$1" ;;
        *.7z)
            7z x "$1" ;;
        *)
            __warn "Unknown file type $1: Skip extract" ;;
    esac
}

__download(){
    # __download url file
    __message "Start downloading $2..."
    if type wget >/dev/null 2>&1
    then
        $debug wget -O "$2" "$1"
    elif type curl >/dev/null 2>&1
    then
        $debug curl --url "$1" --output "$2"
    else
        __exit_with_mes $? "No command to download found"
    fi
}

__download_extract(){
    # __download_extract file url
    # todo: checksum
    __download "$2" "$1" || __exit_with_mes $? "Download failed: $2"
    cd "$srcdir"
    $debug __extract "$1" || __exit_with_mes $? "Extract failed: $1"
}

__fetch_files(){
    if test -z "$source"
    then
        __warn "$No sources to download."
        return 0
    fi

    mkdir -p "$srcdir"
    cd "$srcdir"
    echo "$source" | while read s
    do
        if test -z "$s"
        then
            continue
        fi

        if expr "$s" : ".*::" >/dev/null
        then
            # todo: use expr
            file="$(expr "$s" : '\(.*\)::')"
            url="$(expr "$s" : '.*::\(.*\)$')"
            # file="$(echo "$s" | sed -e 's/::.*$//g')"
            # url="$(echo "$s" | sed -e 's/^.*:://g')"
        else
            url="$s"
            # file="$(echo "$s" | grep -o '[^/]*$')"
            file="$(basename "$s")"
        fi

        if test -f "$file"
        then
            __warn "$file already exists: Skip download"
        else
            __download_extract "$file" "$url"
            cd "$srcdir"
        fi
    done
}

######################################
# main functions
# called under $startdir

__install(){
    __fetch_files
    cd "$startdir"

    __message "Start installing..."
    $debug main "$@" || __exit_with_mes $? "Install failed"
    cd "$startdir"
    __warn "Install done"
}

__show_info(){
    if test -n "$1"
    then
        eval "echo \"$1\""
    else
        echo "Package: $pkgname $pkgver"
        echo "    $pkgdesc"
        echo "URL: $url"
    fi
}

__fetch(){
b    # todo: ? use fetch() if exists
    __fetch_files && __warn "Fetch files done."
}

__clean(){
    # this may be very dengerous
    rm -rf "$srcdir"
}

# help_help(){
#     cat <<__EOC__
# $__script_name help: usage: $__script_name help <command>
# __EOC__
# }

__help(){
    # add support help_*()?
    # if test -n "$1"
    # then
    #     help_"$1"
    #     exit 0
    # fi

    cat <<__EOC__ 1>&2
$__script_name: usage: $__script_name <command> [<option> ...]

Commands:

    install  Install package.
             May accept additional options.
    info     Show info about this package.
    fetch    Only fetch and extract archives.
    help     Display this help message.
    version  Display version info.
__EOC__
# See '$__script_name help <command>' for more information if available.
    if type help_main >/dev/null 2>&1
    then
        echo
        help_main "$@"
    fi
}

__version_info(){
    echo $__script_name v$__version 1>&2
}

__main(){
    cd "$startdir"
    cmd="$1"
    if test -z "$cmd"
    then
        __help
    else
        shift
        case "$cmd" in
            # todo: add do command
            install)
                __install "$@" ;;
            info)
                __show_info "$@" ;;
            fetch)
                __fetch "$@" ;;
            help|--help|-h)
                __help "$@" ;;
            version|--version|-v)
                __version_info "$@" ;;
            __clean)
                __clean "$@" ;;
            __debug)
                set -x
                debug=:
                __install "$@" ;;
            *)
                __message "invalid command: $cmd"
                __help "$@" ;;
        esac
    fi
}

__version=0.2.3

__script_name="$0"
# currently do not overwrite values if already set, but this may change
test -z "$startdir" && startdir="$PWD"
test -z "$srcdir" && srcdir="${startdir}/src-${pkgname}"
# todo: how to do about security?
# how to assure internal codes not changed?
__main "$@"

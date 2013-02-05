#!/bin/sh

pkgname=tmux
pkgver=1.7
pkgdesc="terminal multiplexer"
url=http://tmux.sourceforge.net/

pkg2name=libevent
pkg2ver=2.0.21-stable

source="http://downloads.sourceforge.net/tmux/$pkgname-$pkgver.tar.gz
https://github.com/downloads/libevent/libevent/$pkg2name-$pkg2ver.tar.gz"

_prefix=$HOME/.local

install_tmux(){
    cd $srcdir/$pkgname-$pkgver && \
        LDFLAGS=-L$_prefix/lib CFLAGS=-I$_prefix/include \
        ./configure --prefix=$_prefix && \
        make && \
        make check && \
        make install || return $?
}

install_libevent(){
    cd $srcdir/$pkg2name-$pkg2ver && \
        # when change the directory where this lib is installed,
        # LD_LIBRARY_PATH must include $PREFIX/lib when executing tmux, or use
        # --disable-shared when installing.
        ./configure --prefix=$_prefix && \
        make && \
        make check && \
        make install || return $?
}

main(){
    if test -z "$1"
    then
        install_libevent && install_tmux
    elif test "$1" = $pkg2name
    then
        install_libevent
    elif test "$1" = $pkgname
    then
        install_tmux
    else
        return 1
    fi
}

help_main(){
    cat <<__EOC__ 1>&2
Install arguments:

    `printf '%-9s' $pkgname`Install $pkgname only.
    `printf '%-9s' $pkg2name`Install $pkg2name only.
__EOC__
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
    echo "Package: $pkgname $pkgver"
    echo "    $pkgdesc"
    echo "URL: $url"
}

__fetch(){
b    # todo: use fetch() if exists
    __fetch_files && __warn "Fetch files done."
}

__clean(){
    # this may be very dengerous
    rm -rf $srcdir
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
$__script_name: usage: $__script_name <command> [<args>]

Commands:

    install  Install package.
             May accept additional args.
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
                debug=echo
                __install "$@" ;;
            *)
                __message "invalid command: $cmd"
                __help "$@" ;;
        esac
    fi
}

__version=0.2.1

__script_name="$0"
test -z "$startdir" && startdir="$PWD"
test -z "$srcdir" && srcdir="${startdir}/src-${pkgname}"
# todo: how to do about security?
__main "$@"

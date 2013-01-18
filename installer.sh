#!/bin/sh

pkgname=aaa
pkgvar=1.1-1
pkgdesc="aaa package"
url="http://example.com"
source="$pkgname-$pkgvar.tgz::http://example.com/$pkgname.tgz
http://example.com/$pkgname-addition.tar.gz
git://example.com/git.git"
md5sums=""

build(){
    echo build func
    return 10
}

install(){
    echo install func
}

#######################################
# internal functions

__exit_with_mes(){
    # __exit_with_mes status message
    echo "$__script_name: $2" 1>&2
    exit $1
}

__warn(){
    # __warn message
    echo "$__script_name: $1" 1>&2
}

__match_string(){
    # __match_string str pattern
    echo "$1" | grep "$2" >/dev/null 2>&1
}

__git_clone(){
    # __git_clone dir url
    echo git clone --depth 1 "$2" "$1"
}

__extract(){
    # __extract file
    case "$1" in
        *.tar)
            echo tar xvf "$1" ;;
        *.tar.gz|*.tgz)
            echo tar xvzf "$1" ;;
        *.zip)
            echo unzip "$1" ;;
        *)
            __warn "Did not extract Unknown type: $1" ;;
    esac
}

__download_extract(){
    # __download_extract file url
    # todo: use curl if wget is not avaliable
    if __match_string "$2" "^git://" || __match_string "$2" "\\.git$"
    then
        dir="$(echo "$1" | sed -e 's/\.git$//g')"
        __git_clone "$dir" "$2"
    else
        echo wget -O "$1" "$2" || __exit_with_mes $? "Download failed: $2"
        __extract "$1" || __exit_with_mes $? "Extract failed: $1"
    fi
}

__fetch_files(){
    for s in $source
    # todo: consalt makepkg
    do
        if echo "$s" | grep "::" >/dev/null 2>&1
        then
            file="$(echo "$s" | sed -e 's/::.*$//g')"
            # i want to use lazy match, but POSIX sed not support it
            url="$(echo "$s" | sed -e 's/^.*:://g')"
        else
            url="$s"
            file="$(echo "$s" | grep -o '[^/]*$')"
        fi

        if ! test -f "$file"
        then
            __download_extract "$file" "$url"
        fi
    done
}

######################################
# main functions

__install(){
    __fetch_files
    if type build >/dev/null 2>&1
    then
        build "$@" || __exit_with_mes $? "Build failed"
    fi

    install "$@" || __exit_with_mes $? "Install failed"
}

__show_info(){
    echo "Package: $pkgname $pkgvar"
    echo "    $pkgdesc"
    echo "URL: $url"
}

__fetch(){
    __fetch_files
}

__help(){
    echo help message
}

__main(){
    cmd="$1"
    shift
    case "$cmd" in
        install)
            __install "$@" ;;
        info)
            __show_info "$@" ;;
        fetch)
            __fetch "$@" ;;
        *)
            __help "$@" ;;
    esac
}

__script_name=$0
__main "$@"

#!/bin/zsh
libraries=('glm' 'glfw' 'glew')
for library in $libraries
do
    print -nP "%F{cyan}Installing:%f $library %F{cyan}...%F{red}"
    if [[ $library == 'glfw' ]]
    then
        if [[ ! -f 'glfw*.zip' ]]
        then
            curl -s https://api.github.com/repos/glfw/glfw/releases/latest \
            | grep "browser_download_url.*zip" \
            | cut -d : -f 2,3 \
            | tr -d \" \
            | tail -1 \
            | wget -qi -
        fi
        zipfile=$(ls glfw*.zip)
        print -P "Zip File: %F{blue}$zipfile%f"
        if [[ ! -d 'glfw*' ]]
        then
            unzip -q $zipfile
        fi
        pushd $zipfile[0,-5]
        cmake .
        make -j8
        print -P "%F{cyan}done%f"
        library_location=$(pwd)
        library_name='GLFW_DIR'
        popd
    else
        brew install --quiet $library
        regex="$HOMEBREW_CELLAR/($library/[^[:space:]]+)"
        print -P "%F{cyan}done%f"
        info=$(brew info $library)
        if [[ $info =~ $regex ]]
        then
            library_location='$HOMEBREW_CELLAR'
            library_location="$library_location/${match[1]}"
            case $library in
            'glm')
                library_name='GLM_INCLUDE_DIR'
                library_location="$library_location/include"
                ;;
            'glfw')
                library_name='GLFW_DIR'
                ;;
            'glew')
                library_name='GLEW_DIR'
                ;;
            esac
        else
            print -P "%F{red}doesn't match:%f $info" >&2
            return 1
        fi
    fi
    print -P "%F{green}Found%f %F{yellow}$library%f at %F{magenta}$library_location%f"
    echo "export $library_name=$library_location" >> ~/.zprofile
    print -P "Added %F{yellow}$library%f to %F{magenta}~/.zprofile%f"
done
source ~/.zprofile

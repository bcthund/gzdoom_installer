#!/bin/sh
clear
grey='\033[1;30m'
red='\033[0;31m'
RED='\033[1;31m'
green='\033[0;32m'
GREEN='\033[1;32m'
yellow='\033[0;33m'
YELLOW='\033[1;33m'
purple='\033[0;35m'
PURPLE='\033[1;35m'
white='\033[0;37m'
WHITE='\033[1;37m'
blue='\033[0;34m'
BLUE='\033[1;34m'
cyan='\033[0;36m'
CYAN='\033[1;36m'
NC='\033[0m'

# Save the working directory of the script
working_dir=$PWD

if [ "$1" != "${1#[debug]}" ] ;then
    cmd(){ echo ">> ${WHITE}$1${NC}"; }
    echo "${RED}DEBUG: Commands will be echoed to console${NC}"
else
    cmd(){ eval $1; }
    echo "${RED}LIVE: Actions will be performed! Use caution.${NC}"
fi

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo; echo; exit 0; }
trap ctrl_c INT

echo
echo "${green}==========================================================================${NC}"
echo "${yellow}\tInstall from Source${NC}"
echo "${green}--------------------------------------------------------------------------${NC}"
echo -n "${CYAN}Install gzdoom (y/n)? ${NC}"
read answer
echo
if [ "$answer" != "${answer#[Yy]}" ] ;then
    # Dependencies
        printf "${BLUE}Install Dependencies${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo apt install g++ make cmake libsdl2-dev git zlib1g-dev libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm libgl1-mesa-dev tar libsdl1.2-dev libglew-dev"
        fi
        
    # Create Directories
        echo
        printf "${BLUE}Create tmp directories${NC}"
        if [ -d "./src/gzdoom_tmp" ] ;then
            printf "${BLUE}Temp directory already exists, remove first? ${NC}"
            read answer
            if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "sudo rm -rf ./src/gzdoom_tmp"
            fi
        fi
        cmd "mkdir -pv ./src/gzdoom_tmp/gzdoom/build"
        cmd "mkdir -pv ./src/gzdoom_tmp/zmusic/build"
        
    # Grab Source
        echo
        echo -n "${BLUE}Pull current source from git (requires internet connection) (y/n)? ${NC}"
        read source
        echo
        if [ "$source" != "${source#[Yy]}" ] ;then
            echo "${BLUE}Pulling Zmusic${NC}"
            cmd "git clone https://github.com/coelckers/ZMusic.git ./src/gzdoom_tmp/zmusic/git"
            
            echo
            echo "${BLUE}Pulling gzdoom${NC}"
            cmd "git clone git://github.com/coelckers/gzdoom.git ./src/gzdoom_tmp/gzdoom/git"
        else
            cmd "ln -sr ./src/gzdoom-src/gzdoom/ ./src/gzdoom_tmp/gzdoom/git"
            cmd "ln -sr ./src/gzdoom-src/ZMusic/ ./src/gzdoom_tmp/zmusic/git"
        fi

    # ZMusic: build and install
        echo
        printf "${BLUE}ZMusic: Entering './src/gzdoom_tmp/zmusic/build'${NC}\n"
        cmd "cd ./src/gzdoom_tmp/zmusic/build"
        cmd "ls -al"
        ctrl_c() {
            echo;
            cmd "cd $working_dir"
            cmd "rm -rf ./src/gzdoom_tmp";
            echo;
            exit 0;
        }
        
        echo
        printf "${BLUE}ZMusic: Run 'cmake'${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "cmake ../git/ -DCMAKE_BUILD_TYPE=Release"
        fi
        
        echo
        printf "${BLUE}ZMusic: Run 'make install'${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install"
        fi
        
        echo
        printf "${BLUE}ZMusic: Run 'ldconfig'${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo ldconfig"
        fi
        
        echo
        printf "${BLUE}ZMusic: Leaving './src/gzdoom_tmp/zmusic/build'${NC}\n"
        cmd "cd $working_dir"
        ctrl_c() { echo; echo; exit 0; }

    # gzdoom: build and install
        echo
        printf "${BLUE}gzdoom: Entering './src/gzdoom_tmp/gzdoom/build'${NC}\n"
        cmd "cd ./src/gzdoom_tmp/gzdoom/build/"
        ctrl_c() {
            echo;
            cmd "cd $working_dir"
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo;
            exit 0;
        }
        
        echo
        printf "${BLUE}gzdoom: Run 'cmake'${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            a='' && [ "$(uname -m)" = x86_64 ] && a=64
            c="$(lscpu -p | grep -v '#' | sort -u -t , -k 2,4 | wc -l)"
            [ "$c" -eq 0 ] && c=1
            #rm -f output_sdl/liboutput_sdl.so
            if [ -d ../fmodapi44464linux ] ;then
                f="-DFMOD_LIBRARY=../fmodapi44464linux/api/lib/libfmodex${a}-4.44.64.so -DFMOD_INCLUDE_DIR=../fmodapi44464linux/api/inc";
            else
                f='-UFMOD_LIBRARY -UFMOD_INCLUDE_DIR';
            fi
            cmd "cmake ../git/ -DCMAKE_BUILD_TYPE=Release $f"
        fi
        
        echo
        printf "${BLUE}gzdoom: Run make${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "make -j$c"
        fi
        
        echo
        printf "${BLUE}gzdoom: Leaving './src/gzdoom_tmp/gzdoom/build'${NC}\n"
        cmd "cd $working_dir"
        ctrl_c() {
            echo;
            cmd "rm -rf ./src/gzdoom_tmp";
            echo;
            exit 0;
        }
        
    # Install to Games
        echo
        printf "${BLUE}Install to ~/Games/gzdoom ${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo mv ./src/gzdoom_tmp/gzdoom/build /home/$USER/Games/gzdoom"
        fi
        
        echo
        printf "${BLUE}make install gzdoom${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install -C ./src/gzdoom_tmp/gzdoom/build"
        fi
        
    # Removing build files
        echo
        printf "${BLUE}Remove './src/gzdoom_tmp'${NC}"
        echo -n "${CYAN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "rm -rf ./src/gzdoom_tmp";
        fi
    
    # gzdoom Extras
        echo
        printf "${BLUE}Install Addons - You will need to download the config pack for this to work, see the README.${NC}"
        echo "${YELLOW}\t - gzdoom.ini (will overwrite current settings)${NC}"
        echo "${YELLOW}\t - Brutal Doom${NC}"
        echo "${YELLOW}\t - High Res Texture Pack${NC}"
        echo "${YELLOW}\t - Doom Metal Vol 4${NC}"
        echo "${YELLOW}\t - Heretic High Resolution Textures${NC}"
        echo "${YELLOW}\t - Heretic Music${NC}"
        echo "${YELLOW}\t - Hexen High Resolution Textures${NC}"
        echo "${YELLOW}\t - Hexen Music${NC}"
        echo "${YELLOW}\t - Strife High Resolution Textures${NC}"
        echo "${YELLOW}\t - Strife Voices${NC}"
        echo "${YELLOW}\t - Strife Music${NC}"
        echo "${YELLOW}\t - Chex Quest Music${NC}"
        echo -n "${CYAN}Continue (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo cp --preserve=all -rT ./src/gzdoom_src/config ~/.config/gzdoom";
        fi
    
    ctrl_c() { echo; echo; exit 0; }
    
fi

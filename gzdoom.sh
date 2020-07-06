#!/bin/sh
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

# Setup command
DEBUG=false
VERBOSE=false
FLAGS=""
OTHER_ARGUMENTS=""

for arg in "$@"
do
    case $arg in
        -d|--debug)
        DEBUG=true
        FLAGS="$FLAGS-d "
        shift # Remove --debug from processing
        ;;
        -v|--verbose)
        VERBOSE=true
        FLAGS="$FLAGS-v "
        shift # Remove --verbose from processing
        ;;
        -h|--help)
        echo "${WHITE}"
        echo "Usage: $0.sh <options>"
        echo
        echo "Options:"
        echo "  -h, --help            show this help message and exit"
        echo "  -v, --verbose         print commands being run before running them"
        echo "  -d, --debug           print commands to be run but do not execute them"
        echo "${NC}"
        exit
        shift # Remove from processing
        ;;
        *)
        OTHER_ARGUMENTS="$OTHER_ARGUMENTS$1 "
        echo "${RED}Unknown argument: $1${NC}"
        exit
        shift # Remove generic argument from processing
        ;;
    esac
done

cmd(){
    if [ "$VERBOSE" = true ] || [ "$DEBUG" = true ]; then echo ">> ${WHITE}$1${NC}"; fi;
    if [ "$DEBUG" = false ]; then eval $1; fi;
}

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo; echo; exit 0; }
trap ctrl_c INT

echo
echo -n "${PURPLE}Install gzdoom (y/n)? ${NC}"
read answer
echo
if [ "$answer" != "${answer#[Yy]}" ] ;then
    # Dependencies
        printf "${PURPLE}Source [gzdoom]: ${BLUE}Install Dependencies${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo apt install g++ make cmake libsdl2-dev git zlib1g-dev libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm libgl1-mesa-dev tar libsdl1.2-dev libglew-dev"
        fi
        
    # Create Directories
        echo
        printf "${BLUE}Create Temp Directories${NC}\n"
        if [ -d "./src/gzdoom_tmp" ] ;then
            printf "${PURPLE}Source [gzdoom]: ${BLUE}Build directory already exists, remove first? ${NC}\n"
            printf "${YELLOW}If you leave the directoy, it will be used as-is for building.${NC}\n"
            printf "${BLUE}Remove Directory? ${NC}"
            read answer
            if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "sudo rm -rf ./src/gzdoom_tmp"
            fi
        fi
        
    # Grab Source
        if [ ! -d "./src/valkyrie_tmp" ] ;then
            echo
            echo -n "${PURPLE}Source [gzdoom]: ${BLUE}Pull current source from git (requires internet connection) (y/n)? ${NC}"
            read source
            cmd "mkdir -pv ./src/gzdoom_tmp/gzdoom/build"
            cmd "mkdir -pv ./src/gzdoom_tmp/zmusic/build"
            echo
            if [ "$source" != "${source#[Yy]}" ] ;then
                echo "${PURPLE}Source [gzdoom]: ${BLUE}Pulling Zmusic${NC}"
                cmd "git clone https://github.com/coelckers/ZMusic.git ./src/gzdoom_tmp/zmusic/git"
                
                echo
                echo "${PURPLE}Source [gzdoom]: ${BLUE}Pulling gzdoom${NC}"
                cmd "git clone git://github.com/coelckers/gzdoom.git ./src/gzdoom_tmp/gzdoom/git"
            else
                cmd "ln -sr ./src/gzdoom-src/gzdoom/ ./src/gzdoom_tmp/gzdoom/git"
                cmd "ln -sr ./src/gzdoom-src/ZMusic/ ./src/gzdoom_tmp/zmusic/git"
            fi
        fi

    # ZMusic: build and install
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Entering './src/gzdoom_tmp/zmusic/build'${NC}\n"
        cmd "cd ./src/gzdoom_tmp/zmusic/build"
        cmd "ls -al"
        ctrl_c() {
            echo;
            cmd "cd '${working_dir}'"
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo;
            exit 0;
        }
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Run 'cmake'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "cmake ../git/ -DCMAKE_BUILD_TYPE=Release"
        fi
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Run 'make install'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install"
        fi
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Run 'ldconfig'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo ldconfig"
        fi
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Leaving './src/gzdoom_tmp/zmusic/build'${NC}\n"
        cmd "cd '${working_dir}'"
        ctrl_c() { echo; echo; exit 0; }

    # gzdoom: build and install
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Entering './src/gzdoom_tmp/gzdoom/build'${NC}\n"
        cmd "cd ./src/gzdoom_tmp/gzdoom/build/"
        ctrl_c() {
            echo;
            cmd "cd '${working_dir}'"
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo;
            exit 0;
        }
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Run 'cmake'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
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
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Run make${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "make -j$c"
        fi
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Leaving './src/gzdoom_tmp/gzdoom/build'${NC}\n"
        cmd "cd '${working_dir}'"
        ctrl_c() {
            echo;
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo;
            exit 0;
        }
        
    # Install to Games
        #echo
        #printf "${PURPLE}Source [gzdoom]: ${BLUE}Install to ~/Games/gzdoom ${NC}"
        #echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
        #    cmd "sudo mv ./src/gzdoom_tmp/gzdoom/build /home/$USER/Games/gzdoom"
        #fi
        
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}make install gzdoom${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install -C ./src/gzdoom_tmp/gzdoom/build"
        fi
        
    # Removing build files
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}Remove './src/gzdoom_tmp'${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo rm -rf ./src/gzdoom_tmp";
        fi
    
    # gzdoom Extras
        echo
        printf "${PURPLE}Source [gzdoom]: ${BLUE}Install (A)ddons or (R)estore Backup${NC}"
        echo -n "${GREEN} (a/r)? ${NC}"; read answer; if [ "$answer" != "${answer#[Aa]}" ] ;then
            echo
            printf "${BLUE}Install Addons - You will need to download the config pack for this to work, see the README.${NC}"
            echo "${grey}\t - gzdoom.ini (will overwrite current settings)${NC}"
            echo "${grey}\t - Brutal Doom${NC}"
            echo "${grey}\t - High Res Texture Pack${NC}"
            echo "${grey}\t - Doom Metal Vol 4${NC}"
            echo "${grey}\t - Heretic High Resolution Textures${NC}"
            echo "${grey}\t - Heretic Music${NC}"
            echo "${grey}\t - Hexen High Resolution Textures${NC}"
            echo "${grey}\t - Hexen Music${NC}"
            echo "${grey}\t - Strife High Resolution Textures${NC}"
            echo "${grey}\t - Strife Voices${NC}"
            echo "${grey}\t - Strife Music${NC}"
            echo "${grey}\t - Chex Quest Music${NC}"
            echo -n "${CYAN}Continue (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "sudo cp --preserve=all -rT ./src/gzdoom_src/config ~/.config/gzdoom";
                
            fi
        else
            cmd "sudo rsync -aR --info=progress2 --delete ./Migration_$USER/root/home/$USER/.config/gzdoom/ /home/$USER/.config/gzdoom/"
        fi
    
    ctrl_c() { echo; echo; exit 0; }
    
fi

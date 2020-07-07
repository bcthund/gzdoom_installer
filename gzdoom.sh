#!/bin/bash
grey='\e[37;0m'
GREY='\e[37;1m'
red='\e[31;0m'
RED='\e[31;1m'
green='\e[32;0m'
GREEN='\e[32;1m'
yellow='\e[33;0m'
YELLOW='\e[33;1m'
purple='\e[35;0m'
PURPLE='\e[35;1m'
white='\e[37;0m'
WHITE='\e[37;1m'
blue='\e[34;0m'
BLUE='\e[34;1m'
cyan='\e[36;0m'
CYAN='\e[36;1m'
NC='\e[39;0m'

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
        echo -e "${WHITE}"
        echo -e "Usage: $0 <options>"
        echo -e
        echo -e "Options:"
        echo -e "  -h, --help            show this help message and exit"
        echo -e "  -v, --verbose         print commands being run before running them"
        echo -e "  -d, --debug           print commands to be run but do not execute them"
        echo -e "${NC}"
        exit
        shift # Remove from processing
        ;;
        *)
        OTHER_ARGUMENTS="$OTHER_ARGUMENTS$1 "
        echo -e "${RED}Unknown argument: $1${NC}"
        exit
        shift # Remove generic argument from processing
        ;;
    esac
done

cmd(){
    if [ "$VERBOSE" = true ] || [ "$DEBUG" = true ]; then echo -e ">> ${WHITE}$1${NC}"; fi;
    if [ "$DEBUG" = false ]; then eval $1; fi;
}

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo -e; echo -e; exit 0; }
trap ctrl_c INT

echo -e
echo -e -n "${PURPLE}Install gzdoom (y/n)? ${NC}"
read answer
echo -e
if [ "$answer" != "${answer#[Yy]}" ] ;then
    # Dependencies
        printf "${PURPLE}Source [gzdoom]: ${BLUE}Install Dependencies${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo apt install g++ make cmake libsdl2-dev git zlib1g-dev libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm libgl1-mesa-dev tar libsdl1.2-dev libglew-dev"
        fi
        
    # Create Directories
        echo -e
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
            echo -e
            echo -e -n "${PURPLE}Source [gzdoom]: ${BLUE}Pull current source from git (requires internet connection) (y/n)? ${NC}"
            read source
            cmd "mkdir -pv ./src/gzdoom_tmp/gzdoom/build"
            cmd "mkdir -pv ./src/gzdoom_tmp/zmusic/build"
            echo -e
            if [ "$source" != "${source#[Yy]}" ] ;then
                echo -e "${PURPLE}Source [gzdoom]: ${BLUE}Pulling Zmusic${NC}"
                cmd "git clone https://github.com/coelckers/ZMusic.git ./src/gzdoom_tmp/zmusic/git"
                
                echo -e
                echo -e "${PURPLE}Source [gzdoom]: ${BLUE}Pulling gzdoom${NC}"
                cmd "git clone git://github.com/coelckers/gzdoom.git ./src/gzdoom_tmp/gzdoom/git"
            else
                cmd "ln -sr ./src/gzdoom-src/gzdoom/ ./src/gzdoom_tmp/gzdoom/git"
                cmd "ln -sr ./src/gzdoom-src/ZMusic/ ./src/gzdoom_tmp/zmusic/git"
            fi
        fi

    # ZMusic: build and install
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Entering './src/gzdoom_tmp/zmusic/build'${NC}\n"
        cmd "cd ./src/gzdoom_tmp/zmusic/build"
        cmd "ls -al"
        ctrl_c() {
            echo -e;
            cmd "cd '${working_dir}'"
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo -e;
            exit 0;
        }
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Run 'cmake'${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "cmake ../git/ -DCMAKE_BUILD_TYPE=Release"
        fi
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Run 'make install'${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install"
        fi
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Run 'ldconfig'${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo ldconfig"
        fi
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}ZMusic: Leaving './src/gzdoom_tmp/zmusic/build'${NC}\n"
        cmd "cd '${working_dir}'"
        ctrl_c() { echo -e; echo -e; exit 0; }

    # gzdoom: build and install
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Entering './src/gzdoom_tmp/gzdoom/build'${NC}\n"
        cmd "cd ./src/gzdoom_tmp/gzdoom/build/"
        ctrl_c() {
            echo -e;
            cmd "cd '${working_dir}'"
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo -e;
            exit 0;
        }
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Run 'cmake'${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
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
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Run make${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "make -j$c"
        fi
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}gzdoom: Leaving './src/gzdoom_tmp/gzdoom/build'${NC}\n"
        cmd "cd '${working_dir}'"
        ctrl_c() {
            echo -e;
            cmd "sudo rm -rf ./src/gzdoom_tmp";
            echo -e;
            exit 0;
        }
        
    # Install to Games
        #echo -e
        #printf "${PURPLE}Source [gzdoom]: ${BLUE}Install to ~/Games/gzdoom ${NC}"
        #echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
        #    cmd "sudo mv ./src/gzdoom_tmp/gzdoom/build /home/$USER/Games/gzdoom"
        #fi
        
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}make install gzdoom${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo make install -C ./src/gzdoom_tmp/gzdoom/build"
        fi
        
    # Removing build files
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}Remove './src/gzdoom_tmp'${NC}"
        echo -e -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo rm -rf ./src/gzdoom_tmp";
        fi
    
    # gzdoom Extras
        echo -e
        printf "${PURPLE}Source [gzdoom]: ${BLUE}Install (A)ddons or (R)estore Backup${NC}"
        echo -e -n "${GREEN} (a/r)? ${NC}"; read answer; if [ "$answer" != "${answer#[Aa]}" ] ;then
            echo -e
            printf "${BLUE}Install Addons - You will need to download the config pack for this to work, see the README.${NC}"
            echo -e "${grey}\t - gzdoom.ini (will overwrite current settings)${NC}"
            echo -e "${grey}\t - Brutal Doom${NC}"
            echo -e "${grey}\t - High Res Texture Pack${NC}"
            echo -e "${grey}\t - Doom Metal Vol 4${NC}"
            echo -e "${grey}\t - Heretic High Resolution Textures${NC}"
            echo -e "${grey}\t - Heretic Music${NC}"
            echo -e "${grey}\t - Hexen High Resolution Textures${NC}"
            echo -e "${grey}\t - Hexen Music${NC}"
            echo -e "${grey}\t - Strife High Resolution Textures${NC}"
            echo -e "${grey}\t - Strife Voices${NC}"
            echo -e "${grey}\t - Strife Music${NC}"
            echo -e "${grey}\t - Chex Quest Music${NC}"
            echo -e -n "${CYAN}Continue (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "sudo cp --preserve=all -rT ./src/gzdoom_src/config ~/.config/gzdoom";
                
            fi
        else
            cmd "sudo rsync -a --info=progress2 --delete ./Migration_$USER/root/home/$USER/.config/gzdoom /home/$USER/.config/"
            #cmd "sudo rsync -aR --info=progress2 --delete ./Migration_$USER/root/home/$USER/.config/gzdoom/ /home/$USER/.config/gzdoom/"
        fi
    
    ctrl_c() { echo -e; echo -e; exit 0; }
    
fi

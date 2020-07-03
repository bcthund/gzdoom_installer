# gzdoom_installer
## Description
This is a script I created for a system restore procedure during a fresh install. When upgrading from Ubuntu 18.04 to Kubuntu 20.04 I realized that the snap installation of gzdoom no longer worked giving an error about KDialog. I beleive this was due to the virtual environment that snap packages run in.

So I decided to build gzdoom from source but I carefully documented and scripted the steps as part of a larger script that reinstalls all of my common programs and settings.

The script comes with a copy of gzdoom and zmusic sources that were used when the script was created and can compile from those. The script will give you the option to pull the current sources as well which should work as long as dependencies don't change. If the dependencies have changed then the included source should work provided the distribution has all the dependencies requested to be installed by apt, the full list is below.

Each stage of the script will confirm if you want to continue, giving you the option to stop should errors occur. Pressing CTRL+C is captured and will result in the script automatically removing the temporary build directories.

You are given the option to 'make install' gzdoom if you desire, if you do not then you should say no to removing './src/gzdoom_tmp' when asked. The build will be in './src/gzdoom_tmp/gzdoom/build' which you can put where you like.

The final step will ask if you want to install the Addons which includes Brutal Doom, high resolution textures, and recomposed music as well as a few other items. You will need to download the Addon zip file from [HERE](https://drive.google.com/file/d/1xYo4_OEfLFkCZ7vyHQTBPJ2yC10h0g5g/view?usp=sharing "Download Addons") and extract it into the base folder. You should end up with a './src/gzdoom-src/config' folder. This should be done before starting the gzdoom.sh install script.

## Usage
```chmod +x gzdoom.sh```

<u>**Live run:**</u>  
This will prompt you with a series of questions and perform the actions, making changes to your filesystem.  
```
./gzdoom.sh
```
<br><br>
<u>**Debug:**</u>  
This will prompt you with a series of questions but will not actually perform them. It will echo the command that would be run so you can do a dry run first.  
```
./gzdoom.sh debug
```

## Packages for Reference (installed automatically):
<u>**All Dependencies**</u>
<pre>
  g++
  make
  cmake
  libsdl2-dev
  git
  zlib1g-dev
  libbz2-dev
  libjpeg-dev
  libfluidsynth-dev
  libgme-dev
  libopenal-dev
  libmpg123-dev
  libsndfile1-dev
  libgtk-3-dev
  timidity
  nasm
  libgl1-mesa-dev
  tar
  libsdl1.2-dev
  libglew-dev
</pre>

## Addons
The followind wads and pk3 files can be downloaded from [HERE](https://drive.google.com/file/d/1xYo4_OEfLFkCZ7vyHQTBPJ2yC10h0g5g/view?usp=sharing "Download Addons"). Or they can be downloaded manually by searching for them online. Some of these come with gzdoom already, check in '/usr/local/share/games/doom/' for them.
<pre>
  gzdoom.ini
  brightmaps.pk3
  brutalv20b_R.pk3
  ChexPK3.pk3
  DoomMetalVol4.wad
  ExtraTextures.wad
  freedoom.wad
  game_support.pk3
  gzdoom.pk3
  hellonearthstarterpack.wad
  heretic_high_resolution_pack.pk3
  HereticPK3.pk3
  hexen_high_resolution_pack.pk3
  hexen_v2_pk3.pk3
  lights.pk3
  StrifePK3.pk3
  voices.wad
  zdoom-dhtp-20171001.pk3
</pre>

## Configured Wads - Not Provided Here
These are the names of the game wad files the gzdoom.ini file included with Addons is configured with.
<pre>
  chex.wad
  chex3.wad
  doom.wad
  doom1.wad
  doom2.wad
  doomu.wad
  heretic.wad
  hexdd.wad
  hexen.wad
  plutonia.wad
  strife1.wad
  tnt.wad
</pre>

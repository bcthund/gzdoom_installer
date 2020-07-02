# gzdoom_installer
This is a script I created for a system restore procedure during a fresh install. When upgrading from Ubuntu 18.04 to Kubuntu 20.04 I realized that the snap installation of gzdoom no longer worked giving an error about KDialog. I beleive this was due to the virtual environment that snap packages run in.

So I decided to build gzdoom from source but I carefully documented and scripted the steps as part of a larger script that reinstalls all of my common programs and settings.

The script comes with a copy of gzdoom and zmusic sources that were used when the script was created and can compile from those. The script will give you the option to pull the current sources as well which should work as long as dependencies don't change. If the dependencies have changed then the included source should work provided the distribution has all the dependencies requested to be installed by apt, the full list is below.

Each stage of the script will confirm if you want to continue, giving you the option to stop should errors occur. Pressing CTRL+C is captured and will result in the script automatically removing the temporary build directories. The second to last step is to install into ~/Games/gzdoom by default. If you don't do this then you need to say no to removing './src/gzdoom_tmp' in the last step. You can move the './src/gzdoom_tmp/gzdoom' folder to wherever you want or 'sudo make install' if you desire.

# Packages for Reference (installed automatically):
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

# Addons
The followind wads and pk3 files can be downloaded from "here...coming soon". Or they can be downloaded manually by searching for them online. Some of these come with gzdoom already, check in '/usr/local/share/games/doom/' for them.
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

# Configured Wads - Not Provided Here
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


# From the Depths

From The Depths is a minimalistic real-time strategy game. A series of
relentless earthquakes proved a throwback to civilization, and from the fissures
across the globe enormous monsters emerged. Though not particularly menacing,
their bottomless hunger threatens the scarce supplies humanity fights every day
for in this devasted world. You must manage the workers who brave the wastelandsto make sure humanity does not starve.

## Instructions

There are two ways to run this game, described below:

### Method 1: run the pre-compiled binary (Debian/Ubuntu only)

First, install these dependencies:

```bash
apt-get install build-essential autotools-dev automake libtool pkg-config libdevil-dev libfreetype6-dev libluajit-5.1-dev libphysfs-dev libsdl2-dev libopenal-dev libogg-dev libvorbis-dev libflac-dev libflac++-dev libmodplug-dev libmpg123-dev libmng-dev libturbojpeg libtheora-dev
```

Or, on Debian Wheezy:

```bash
aptitude install build-essential automake libtool libphysfs-dev libsdl-dev libopenal-dev liblua5.1-0-dev libdevil-dev libmodplug-dev libfreetype6-dev libmpg123-dev libvorbis-dev libmng-dev libxpm-dev libxcursor-dev libXxf86vm-dev
```

Download the latest pre-compiled binaries from the [releases
page](https://github.com/Kazuo256/from-the-depths/releases), extract it, and
run the following commands:

```bash
$ chmod +x from-the-depths run.sh
$ ./run.sh
```

### Method 2: use LÖVE

First, install LÖVE 0.10.2 (it HAS to be this exact version) on your system.
Then download this repository.

On Unix systems, enter the repository folder and run:

```bash
love game
```

On Windows, create a shortcut of the LÖVE executable in your desktop, then
drag nd drop the "game" folder on it.


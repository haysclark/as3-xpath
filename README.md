AS3-XPath
========================
[![Build Status](https://travis-ci.org/haysclark/as3-xpath.svg?branch=master)](https://travis-ci.org/haysclark/as3-xpath])

Build SWC
-------
Build swc via Maven
```
mvn flexmojos:compile-swc
```

Run Tests
-------

Download and install a specific Flash Player from the [Adobe Archives.](http://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html)

```
sh getFpFromArchive 'http://download.macromedia.com/pub/flashplayer/installers/archive/fp_11.7.700.225_archive.zip'
```

Add the Flash Player path to $PATH so that Java can find the Flash Player. (required by Flex-Mojos 4.x)

```
export PATH="Flash Player Debugger.app/Contents/MacOS":$PATH
```

FLex-Mojo is expecting the "Flash Player" command so copy "Flash Player Debug" to "Flash Player"

```
cp Flash\ Player\ Debugger.app/Contents/MacOS/Flash\ Player\ Debugger Flash\ Player\ Debugger.app/Contents/MacOS/Flash\ Player
```

Run UnitTest via Maven

```
mvn test
```

License
-------
Copyright (c) 2014 Hays Clark <br>
Copyright (c) 2007 Memorphic Ltd.
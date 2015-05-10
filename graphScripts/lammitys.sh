#!/bin/bash

rrdtool graph - \
 --start=end-$ShortTime \
 --title=Lammitys \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:f=$RRADIR//muuri.rrd:temp:AVERAGE \
 LINE1:f#DD3300:muuri \
 GPRINT:f:MIN:Min%8.2lf%s\
 GPRINT:f:AVERAGE:Avg%8.2lf%s\
 GPRINT:f:MAX:Max%8.2lf%s\
 GPRINT:f:LAST:Last%8.2lf%s > $OutDir/lammitys.png

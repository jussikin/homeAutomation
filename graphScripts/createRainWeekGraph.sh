#!/bin/bash

XSize=800
YSize=300
ShortTime=7d
OutDir=~/public_html/viikko/graphs/

rrdtool graph - \
 --start=end-$ShortTime \
 --title=Sademaara \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 --step=21600 \
 DEF:b=/home/jussikin/rrd/sademaara.rrd:rain:AVERAGE \
 CDEF:c=b,72,* \
 "AREA:c#0000FF:sade mm"> $OutDir/sade.png

rrdtool graph - \
 --start=end-$ShortTime \
 --title=Ilmanpaine \
 --vertical-label 'Preassure in Millibars' \
 --imgformat=PNG \
 --width=$XSize \
 --height=$YSize \
 --interlaced \
 --step=300 \
 -A -l 900 -u 1100 \
 -L 10 -X 0 \
 DEF:b=/home/jussikin/rrd/ulkopaine.rrd:preassure:AVERAGE \
 CDEF:c=b,100,/ \
 "LINE:c#0000FF:paine"> $OutDir/preassure.png


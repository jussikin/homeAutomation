rrdtool graph - \
 --start=end-$ShortTime \
 --title=Palkinpaa \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:b=$RRADIR/auto.rrd:temp:AVERAGE \
 DEF:c=$RRADIR/palkinpaa.rrd:temp:AVERAGE \
 LINE1:b#0000FF:auto \
 LINE1:c#FF00FF:palkinpaa \
 GPRINT:b:MIN:Min%8.2lf%s\
 GPRINT:b:AVERAGE:Avg%8.2lf%s\
 GPRINT:b:MAX:Max%8.2lf%s\
 GPRINT:b:LAST:Last%8.2lf%s > $OutDir/palkinpaa.png

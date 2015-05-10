rrdtool graph - \
 --start=end-$ShortTime \
 --title=Kasvihuone \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:b=$RRADIR/kasvihuone.rrd:temp:AVERAGE \
 DEF:c=$RRADIR/vesi.rrd:temp:AVERAGE \
 LINE1:b#0000FF:kasvihuone \
 LINE1:c#000000:vesi \
  GPRINT:b:MIN:Min%8.2lf%s\
 GPRINT:b:AVERAGE:Avg%8.2lf%s\
 GPRINT:b:MAX:Max%8.2lf%s\
 GPRINT:b:LAST:Last%8.2lf%s > $OutDir/kasvihuone.png

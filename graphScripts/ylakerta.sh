rrdtool graph - \
 --start=end-$ShortTime \
 --title=Ylakerta \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:b=$RRADIR/ylakerta.rrd:temp:AVERAGE \
 DEF:c=$RRADIR/sannanhuone.rrd:temp:AVERAGE \
 DEF:d=$RRADIR/jussinhuone.rrd:temp:AVERAGE \
 LINE1:b#00BB55:avg \
 LINE1:d#002288:jussinhuone \
 LINE1:c#AADD00:sannanhuone \
 GPRINT:b:MIN:Min%8.2lf%s\
 GPRINT:b:AVERAGE:Avg%8.2lf%s\
 GPRINT:b:MAX:Max%8.2lf%s\
 GPRINT:b:LAST:Last%8.2lf%s > $OutDir/ylakerta.png

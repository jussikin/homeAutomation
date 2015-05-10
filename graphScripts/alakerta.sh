rrdtool graph - \
 --start=end-$ShortTime \
 --title=Alakerta \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:b=$RRADIR/keittio.rrd:temp:AVERAGE \
 DEF:c=$RRADIR/olohuone.rrd:temp:AVERAGE \
 DEF:d=$RRADIR/kuisti.rrd:temp:AVERAGE \
 DEF:e=$RRADIR/kodinhoitohuone.rrd:temp:AVERAGE \
 DEF:g=$RRADIR/makuuhuone.rrd:temp:AVERAGE \
 LINE1:b#FF0000:keittio \
 LINE1:c#FFBB00:olohuone \
 LINE1:d#0088BB:kuisti \
 LINE1:e#0033DD:kodinhoitohuone \
 LINE1:g#DD55FF:makkari \
 GPRINT:g:MIN:Min%8.2lf%s\
 GPRINT:g:AVERAGE:Avg%8.2lf%s\
 GPRINT:g:MAX:Max%8.2lf%s\
 GPRINT:g:LAST:Last%8.2lf%s > $OutDir/alakerta.png

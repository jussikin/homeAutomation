rrdtool graph - \
 --start=end-$ShortTime \
 --title=Ulkotilanne \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:a=$RRADIR/kasvihuone.rrd:temp:AVERAGE \
 DEF:b=$RRADIR/ulko.rrd:temp:AVERAGE \
 DEF:c=$RRADIR/puutarha.rrd:temp:AVERAGE \
 DEF:d=$RRADIR/kukkatarha.rrd:temp:AVERAGE \
 DEF:e=$RRADIR/saunamokki.rrd:temp:AVERAGE \
 DEF:f=$RRADIR/maa.rrd:temp:AVERAGE \
 LINE1:a#0000FF:kasvihuone \
 LINE1:b#00FF00:ulkolampo \
 LINE1:c#008844:puutarha \
 LINE1:d#88BB00:kukkatarha \
 LINE1:e#DD0033:saunamokki \
 LINE1:f#000000:maa \
 GPRINT:b:MIN:Min%8.2lf%s\
 GPRINT:b:AVERAGE:Avg%8.2lf%s\
 GPRINT:b:MAX:Max%8.2lf%s\
 GPRINT:b:LAST:Last%8.2lf%s > $OutDir/ulkotilanne.png

rrdtool graph - \
 --start=end-$ShortTime \
 --title=MokinTilanne \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --interlaced \
 DEF:b=$RRADIR/saunamokki.rrd:temp:AVERAGE \
 DEF:c=$RRADIR/kosteus.rrd:moisture:AVERAGE \
 DEF:d=$RRADIR/ulkokosteus.rrd:moisture:AVERAGE \
 LINE1:c#55AAFF:sisakosteus \
 LINE1:d#FF0011:ulkokosteus \
 LINE1:b#DD00AA:lampo > $OutDir/mokki.png

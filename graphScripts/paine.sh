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
 DEF:d=/home/jussikin/rrd/sisapaine.rrd:preassure:AVERAGE \
 CDEF:c=b,100,/ \
 CDEF:e=d,100,/ \
 "LINE:e#FF00FF:sisapaine" \
 "LINE:c#0000FF:ulkopained"> $OutDir/preassure.png

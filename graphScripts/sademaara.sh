rrdtool graph - \
 --start=end-$ShortTime \
 --title=Sademaara \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --right-axis-format %2.3lf \
 --x-grid HOUR:1:HOUR:1:HOUR:1:0:%H \
 --interlaced \
 --step=3600 \
 DEF:b=/home/jussikin/rrd/sademaara.rrd:rain:AVERAGE \
 CDEF:c=b,12,* \
 "AREA:c#0000FF:sade mm"> $OutDir/sade.png

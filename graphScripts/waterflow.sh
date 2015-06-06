rrdtool graph - \
 --start=end-$ShortTime \
 --title=Kastelu  \
 --imgformat=PNG \
 --width=$XSize \
 --base=1000 \
 --height=$YSize \
 --right-axis 1:0 \
 --right-axis-format %2.3lf \
 --x-grid HOUR:1:HOUR:1:HOUR:1:0:%H \
 --interlaced \
 --step=3600 \
 DEF:b=/home/jussikin/rrd/waterflow.rrd:rain:AVERAGE \
 CDEF:c=b,12,* \
 "AREA:c#0000FF:kastelua litraa"> $OutDir/waterflow.png

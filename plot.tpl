#set term pngcairo dashed size 600,450 enhanced font 'Verdana,10'
#set xlabel  "x" 
#set ylabel "y = real(sin(x)**besj0(x))"
#
#set samples 400
#
#set output 'nameOfTheImage.png'
#
#plot [-10:10] real(sin(x)**besj0(x))


#-------------------------------------
set terminal svg size 600,450 fname 'Verdana' fsize 10

set samples 800, 800

set xlabel  "x" 
set ylabel "y = sin(x*20)*atan(x)"

set output 'svgImage.svg'
plot [-30:20] sin(x*20)*atan(x)

#replot


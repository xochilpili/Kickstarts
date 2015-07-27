#!/bin/bash
#
# trying to edit gnome-shell.css 

#sed -n '/^#lockDialogGroup {/,/^$/p' original.css > out.css 
#sed -i 's/background: #2e3436 url(resource:\/\/\/org\/gnome\/shell\/theme\/noise-texture.png);/background: #2e3436 url(black_pirate_flag.jpg);/g' out.css
#sed -i 's/background-repeat: repeat; \}/background-repeat: no-repeat;/g' out.css
#echo "   background-size:cover;" >> out.css
#echo "   background-position: center center;" >> out.css
#echo "}" >> out.css
input="original.css"
arr=($(sed -n '/^#lockDialogGroup {/,/^$/p' original.css))
arr=("${arr[@]%%}");
for a in "${arr[@]}"
	do
		echo $a
done
#while IFS= read -r line; do
#    case "$line" in *#lockDialogGroup*) 
		#i=1 
		#break;;
#		echo "$line";;
#         *) i=0
#    esac
#done <"$input"
#echo $i in "$input";
echo "done"

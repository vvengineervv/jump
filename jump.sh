#!/bin/bash -e


MYFILE=$(mktemp tmpXXXX)
trap "rm $MYFILE" EXIT

case "$1" in
    e)
        SIZE=$(find ${2:-.} -type f -exec ls -lnq {} \+ | awk '
        BEGIN {sum=0} # initialization for clarity and safety
        function pp() {
         v=sum;
         printf("%d\n", sum);
        }
        {sum+=$5}
        END{pp()}') 

        for n in $(seq 1000 1 1500); do
           STR=$( printf %04d "$n" ).jump
           X=1
           if (( (n % 2) != 0)); then
               X=-1
           fi
           if [ "$STR" != "$2" ]; then
               S=$(($SIZE + $X * ($RANDOM % ($SIZE/2))))
               dd if=/dev/urandom of=$STR bs=1 count=$S
           fi
        done
        for i in $(ls -d *jump)
        do
            tar zcvf $MYFILE $i
            if [ "$i" == "$2" ]; then
                openssl aes-256-cbc -a -salt -in $MYFILE -out $i.pub -md sha256
            else 
                echo $RANDOM | openssl aes-256-cbc -a -salt -in $MYFILE -out $i.pub -pass stdin -md sha256
            fi
        done
        ;;
    d)
        openssl aes-256-cbc -d -a -in $2 -out $MYFILE -md sha256
        tar xvzf $MYFILE
        ;;
    *)
	    echo "usage $0 <e|d> <target>"
esac


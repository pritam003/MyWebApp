#!/bin/ksh
export node=`uname -a|awk '{print $2}' | cut -b 10-11`
cd /var/log/temp
if [ -f final_op.txt ]
then
rm -f final_op.txt
fi
df -k|grep "%">temp.txt
count=`cat temp.txt|wc -l`
ct=`expr $count - 1 `
tail -$ct temp.txt>temp1.txt
cut -c 10- temp1.txt>temp2.txt
tr ' ' ','<temp2.txt>temp3.txt
tr -s ',' <temp3.txt>temp4.txt
cut -d "," -f5,6 temp4.txt>temp5.txt

for i in `cat temp5.txt`
do
space=`echo $i|cut -d "%" -f1`
mount=`echo $i|cut -d "," -f2`
if [ $mount = "/var/log" ]
then
if [ $space -gt 70 ]
then
echo $space"%" $mount>>final_op.txt
fi
fi
done

fc=`cat final_op.txt|wc -l`
if [ $fc -eq 0 ]
then
rm temp*
rm final_op.txt
rm mail_body.txt
exit 0;
else
echo "Hi Team,">mail_body.txt
echo ' '>>mail_body.txt
echo " ">>mail_body.txt
echo "Below mount points are getting full of PROD$node Please take action immediately,">>mail_body.txt
echo "  ">>mail_body.txt
echo "  ">>mail_body.txt
cat final_op.txt>>mail_body.txt
echo '  '>>mail_body.txt
echo "  ">>mail_body.txt
echo "Thanks,">>mail_body.txt
echo "AWS Team">>mail_body.txt
subject="Alert!Mount Point Full on PRODSDC$node `date +%A`,`date +"%d-%h-%Y"` at `date +"%H:%M:%S"` BST"
cat mail_body.txt| mailx -s  "$subject" 'tean@demo.com'
rm temp*
rm final_op.txt
rm mail_body.txt
exit 0;
fi
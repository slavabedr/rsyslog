# This one sends quite a lot of CEE-formatted logs via TCP
# and checks if they are all parsed and written into the
# log file. Parsing of those logs is done via mmjsonparse.
# You can look at the configuration in testsuites/mmjsonparse-basic.conf
echo [mmjsonparse-basic.sh]

TIMES_TO_SEND=50000 #how many times to send each log from the test file

function check_log {
# checks if rsyslog.out.log has the $1 string (and only that string)
# on every line the number of times we expect
        LINE=$1
	TIMES_WRITTEN=`grep -c "^$LINE$" $srcdir/rsyslog.out.log`
	if [ ! $TIMES_WRITTEN -eq $TIMES_TO_SEND ]; then
                echo
                echo "whoops! Expecting $TIMES_TO_SEND logs to match '$LINE', but only $TIMES_WRITTEN matched!"
		exit 1 #fail the test if it's not what we expect
	fi
}

############START THE TEST######################
source $srcdir/diag.sh init
#start rsyslog
source $srcdir/diag.sh startup mmjsonparse-basic.conf

#make the test file with CEE-formatted logs and send it $TIMES_TO_SEND times
echo '<82>Mar  1 01:00:00 172.20.245.8 tag @cee: {"foo": 1}
<82>Mar  1 01:00:00 172.20.245.8 tag @cee: {"foo": 2}' > ceetest.in
$srcdir/tcpflood -I ceetest.in -C $TIMES_TO_SEND

#give it a chance to start processing
sleep 1

source $srcdir/diag.sh shutdown-when-empty # shut down rsyslogd when done processing messages
source $srcdir/diag.sh wait-shutdown    # we need to wait until rsyslogd is finished!
#cleanup the test file
rm ceetest.in

#check if in rsyslog.out.log has what we expect
check_log 1
check_log 2

# this test uses omelasticsearch to send logs one by one to
# your Elasticsearch server on localhost:9200, to the rsyslog-test
# index. Then checks if all logs got to the destination
#
# This is a "common" script, called by other omelasticsearch tests
# so far the parameter is the conf file ($1)
CONF_FILE=$1

SENT_LOGS=50000 #how many times to send each log from the test file

############START THE TEST######################
#check if the "rsyslog-test" index exists
CODE=`curl -Is 'http://localhost:9200/rsyslog-test' | head -n1 | cut -d ' ' -f 2`
if [ $CODE -eq 200 ]; then
	echo "You already have an index called 'rsyslog-test' and I'm afraid to delete it"
	exit 1
fi

source $srcdir/diag.sh init
#start rsyslog
source $srcdir/diag.sh startup $CONF_FILE

#
$srcdir/tcpflood -m $SENT_LOGS

#give it a chance to start processing
echo "Waiting for rsyslog to finish processing and shutting it down..."
sleep 1

source $srcdir/diag.sh shutdown-when-empty # shut down rsyslogd when done processing messages
source $srcdir/diag.sh wait-shutdown    # we need to wait until rsyslogd is finished!

#refresh the index and wait for a second, to have all logs ready for search
curl localhost:9200/rsyslog-test/_refresh; echo
sleep 1

echo -n "Checking the number of indexed logs..."
INDEXED_LOGS=`curl -s 'localhost:9200/rsyslog-test/test-type/_search?size=0&pretty' | grep -A1 "hits\" : {" | grep "total" | cut -d ' ' -f 7 | sed s/,//`
if [ ! $SENT_LOGS -eq $INDEXED_LOGS ]; then
	echo "Expected $SENT_LOGS logs, got $INDEXED_LOGS indexed"
	exit 1
fi
curl -XDELETE localhost:9200/rsyslog-test/; echo

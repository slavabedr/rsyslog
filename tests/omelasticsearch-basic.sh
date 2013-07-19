# sends some 50K logs via tcpflood and waits for rsyslog
# to send them to ES. Then checks if all the 50K logs
# can be found

echo ===============================================================================
echo \[omelasticsearch-basic.sh\]: sending logs to Elasticsearch one by one

source $srcdir/omelasticsearch-common.sh omelasticsearch-basic.conf

# sends some 50K logs via tcpflood and waits for rsyslog
# to send them to ES in bulks of 100. Then checks if all 
# the 50K logs can be found

echo ===============================================================================
echo \[omelasticsearch-bulk.sh\]: sending logs to Elasticsearch in bulks

source $srcdir/omelasticsearch-common.sh omelasticsearch-bulk.conf

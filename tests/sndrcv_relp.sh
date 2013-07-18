# This runs sends and receives messages via RELP to port 20514
# we're sending 50K messages to actually test if messages
# still arrive even if they are many
echo ===============================================================================
echo \[sndrcv_relp.sh\]: testing sending and receiving via udp
if [ "$EUID" -ne 0 ]; then
    exit 77 # Not root, skip this test
fi
source $srcdir/sndrcv_drvr.sh sndrcv_relp 50000

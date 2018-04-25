RESPONSE_CODE=""
printf 'Waiting for Apache\n'
while [ -z "$RESPONSE_CODE" ]
do
    RESPONSE_CODE=$(curl -s -I http://127.0.0.1 | grep HTTP | awk {'print $2'})
    sleep 2
done
printf 'Apache ready. Starting Varnish\n'
/usr/sbin/varnishd -s malloc,${VARNISH_CACHE_SIZE} -a ${HOST_IP}:${VARNISH_PORT} -b ${VARNISH_BACKEND_ADDRESS}:${VARNISH_BACKEND_PORT}

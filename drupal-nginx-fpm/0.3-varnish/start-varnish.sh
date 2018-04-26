RESPONSE_CODE=""
printf 'Waiting for Nginx\n'
while [ -z "$RESPONSE_CODE" ]
do
    RESPONSE_CODE=$(curl -s -I http://localhost:8080 | grep HTTP | awk {'print $2'})
    sleep 2
done
printf 'Nginx ready. Starting Varnish\n'
/usr/sbin/varnishd -s malloc,${VARNISH_CACHE_SIZE} -a ${HOST_IP}:${VARNISH_PORT} -b ${VARNISH_BACKEND_ADDRESS}:${VARNISH_BACKEND_PORT}

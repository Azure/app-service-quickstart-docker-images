until $(curl --output /dev/null --silent --head --fail http://127.0.0.1:80); do
    printf 'Apache not ready ... Retrying in 1s'
    sleep 1
done
printf 'Apache ready. Starting Varnish'
/usr/sbin/varnishd -s malloc,${VARNISH_CACHE_SIZE} -a ${HOST_IP}:${VARNISH_PORT} -b ${VARNISH_BACKEND_ADDRESS}:${VARNISH_BACKEND_PORT}
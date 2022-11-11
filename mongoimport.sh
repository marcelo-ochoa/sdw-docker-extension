# https://apexapps.oracle.com/pls/apex/r/dbpm/livelabs/run-workshop?p210_wid=831
export URI='mongodb://scott:tiger@host.docker.internal:27017/scott?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/idaqt8axawdx/b/products/o/products.ndjson -o products.ndjson
docker run --rm -v $(pwd)/products.ndjson:/tmp/products.ndjson rtsp/mongosh mongoimport --verbose --tlsInsecure --collection products --uri $URI --file=/tmp/products.ndjson

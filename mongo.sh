export URI='mongodb://scott:tiger@host.docker.internal:27017/scott?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
docker run --rm -it rtsp/mongosh mongosh --tlsAllowInvalidCertificates --verbose $URI

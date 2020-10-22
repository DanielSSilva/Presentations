# Pulling the image and running it

docker pull ironmansoftware/universal
docker run --name 'powershellUniversal' -it -p 5000:5000 -d ironmansoftware/universal 

# Creating a Persistent data
## Building a custom image defining env variables
docker build -f ./PersistentData/persistentdata.dockerfile --tag=psu-persistent .

## Running the newly created image with mount
docker run --name PSU_persistent \
    --mount source=psudata,target=/data \
    -p 5000:5000/tcp \
    -d psu-persistent:latest

> Issue: only /data is persisted. This is ok if you just want to persist PowerShell Universal information

# Creating a image with preloaded scripts 
docker build -f ./preloaded.dockerfile --tag=psu-preloaded .

docker run --name PSU_preloaded \
    -p 5000:5000/tcp\
    -v path/to/mountedVolume:/sharedFolder \
    -d psu-preloaded:latest



# Solr

Docker image containing a standard Solr distribution.

Versions used in this docker image:
* Solr Version: 5.4.1
* Java 1.8.0_72

Image details:
* Installation directory: /usr/local/apache-solr/current

## Solr Docker image

To start the Solr Docker image:

    docker run -i -t bde2020/solr /bin/bash
    
To build the Solr Docker image:

 ```bash
git clone https://github.com/big-data-europe/solr.git
docker build -t bde2020/solr .
```
To create a distributed Solr index.
* Upload Solr configuration to zookeeper
  To bootstrap the Solr configuration inside zookeeper the following files are required
  * security.json
  * clusterprops.json
  * solr.xml
  
  It is possible to use any available tool to upload these file to zookeeper. 
  The recommended way is to use Solr's zkcli.sh to upload Solr configuration files. This script offers the possibility to upload a whole config directory at once to zookeeper. The script is available inside a running docker image under /usr/local/apache-solr/current/server/scripts/cloud-scripts. 
  The following commands upload a sample configuration from the Solr distribution and solr.xml (must be in zookeeper chroot) to zookeeper
  ```bash
./zkcli.sh \
  -zkhost 192.168.88.219:2181/solr \
  -cmd upconfig \
  -confdir ../../solr/configsets/basic_configs/conf/ \
  -confname basic_config
```
  ```bash
./zkcli.sh \
  -zkhost 192.168.88.219:2181/solr \
  -cmd putfile /solr.xml ../../solr.xml 
```
  see: https://cwiki.apache.org/confluence/display/solr/Using+ZooKeeper+to+Manage+Configuration+Files for more information on setting up Solr's configuration in zookeeper.
  
* Start Solr Cloud
  
  If the above required config files are present in a zookeeper node it is possible to start Solr in cloud mode.
  Use the following command to startup Solr in cloud mode. Note that it is recommended to use a mapped directory
  as Solr home (this will ensure that indexes survive a docker image restart). For this guide it is assumed that
  /var/lib/bde/solr will act as Solr home and that said directory is mapped to the host where the docker image runs.
  In case it doesn't already exist, the directory can be created with
  ```bash
mkdir -p /var/lib/solr
```
  Solr Cloud is started with the following command. Notes: -f = run in foreground, -cloud = run in cloud mode, -s = use the specified directory as Solr home, -p = the port Solr will be available trough, -z = the zookeeper path with chroot
  ```bash
cd /usr/local/apache-solr/current && \
.bin/solr start \
  -f \
  -cloud \
  -s /var/lib/solr \
  -p 8983 \
  -z 192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/solr
```

* Use Solr's HTTP API to create a the distributed index

  To create a distributed (sharded) index it is now possible to use Solr's HTTP API.
  ```bash
  http://bigdata-one.example.com:8983/solr/admin/collections?action=CREATE&name=SampleCollection&numShards=3&replicationFactor=1&collection.configName=basic_config
```
  Notes: With the above service call a new collection is created, it's name is SampleCollection, the number of shards is three, a replication factor of 1 is used and the collection will be based on the "basic_config" configuration, that was uploaded to zookeeper in the previous step.

To start Solr Docker image on Marathon:

* Create a Marathon Application Setup in json like the one below, store it in a file (e.g. marathon-solr.json) and post it to Marathon's v2/app endpoint.

 ```json
{
    "container": {
        "type": "DOCKER",
        "volumes": [
        {
                "containerPath": "/var/lib/solr",
                "hostPath": "/var/lib/bde/solr",
                "mode": "RW"
        }
        ],
        "docker": {
            "network": "HOST",
            "privileged":true,
            "image": "bde2020/solr"
        }
    },
    "id":"apache-solr",
    "mem": 1024,
    "cpus":0.3,
    "cmd": "mkdir -p /var/lib/solr && /usr/local/apache-solr/current/bin/solr start -f -cloud -s /var/lib/solr -p 8983 -z 192.168.88.219:2181,192.168.88.220:2181,192.168.88.221:2181/solr",
    "instances":0,
    "requirePorts":true,
    "ports":[8983,7983],
    "constraints":[["hostname","UNIQUE",""]]
}
```

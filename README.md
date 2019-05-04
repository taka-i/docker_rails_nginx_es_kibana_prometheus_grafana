# docker_rails_nginx_es_kibana_prometheus_grafana
development environement for rails + nginx + elasticsearch + prometheus

* Application: Ruby on rails
* Web Server: Nginx
* log collector: fluentd
* An open-source monitoring system: prometheus + grafana
* An open-soruce log analysis: elasticsearch + kibana

# developed environement
Docker tool box for windows (Windows 10 Home)

# required environment
one of the following:
* Docker for mac
* Docekr for windows
* Docker tool box for windows

# How to build
```
git clone https://github.com/taka-i/docker_rails_nginx_es_kibana_prometheus_grafana.git
cd docker_rails_nginx_es_kibana_prometheus_grafana/docker
docker-compose build
```

# Launch application with docker-compose
```
cd docker_rails_nginx_es_kibana_prometheus_grafana/docker
docker-compose up -d
```

# shutdown all containers
```
cd docker_rails_nginx_es_kibana_prometheus_grafana/docker
docker-compose down
```

# Verify the operation
## For Docker tool box for windows
you need to adjust Oracle Virtual Box setting:
 1. In Oracle Virtual Box Manager, select default image(boot2docker image)
 2. go to setting -> set main memory capacity to at least 4 GB
 3. setting -> set CPU core at least 2
 4. network -> advanced -> add port forward settting:
    Host port : Guest Port
    443 : 443 (nginx)
    3000 : 3000 (grafana)
    5601 : 5601 (kibana)
    9090 : 9090 (prometheus)
    9100 : 9100 (node exporter)
    9200 : 9200 (elasticsearch)
 5. (optional)
    elasticsearch requires vm.max_map_count certain ammount
    if you remove environment variable: discovery.type=single-node
    this is discovery setting is for development,
    so if you consider using in staging or production environment you need to remove that variable.
    Using quick docker terminal,
    ```
    $ docker-machine.exe ssh
       ( '>')
      /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
     (/-_--_-\)           www.tinycorelinux.net

    docker@default:~$ sudo sysctl -w vm.max_map_count=262144
    ```
    in the docker-compose.yml,
    remove the comment out and activate volume setting
    ```
    elasticsearch:
      image: elasticsearch:7.0.0
      environment:
        - discovery.type=single-node
      # volumes:
        # - ./containers/es/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      ports:
        - "9200:9200"
    ↓
    elasticsearch:
      image: elasticsearch:7.0.0
      environment:
        - discovery.type=single-node
      volumes:
        - ./containers/es/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      ports:
        - "9200:9200"
    ```
    ! ./containers/es/config/elasticsearch.yml IS NOT TESTED !  
    ! READ OFFICIAL DOCUMENT AND SET THE VARIABLE !

## wait for rails application to launch and ready
in the first launch, rails new command is executed and initialize rails application in docker-entorypoint.sh
wait for the initialization and puma is ready
you can check the log:
```
$ docker logs -f docker_app_1
...
Puma starting in single mode...
* Version 3.12.1 (ruby 2.6.3-p62), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on unix:///data-shared-volume/puma.sock
Use Ctrl-C to stop
```

## Access localhost for rails initial page
https://localhost/
because https and own certification, chrome browser will warn you to stop seeing the page
so proceed to the page anyway

## Nginx log output
```
tail -f volumes/web/log/access.log
tail -f volumes/web/log/error.log
```

## fluentd logs
nginx logs are outputted to standard error
so if you tail the fluentd container standard error you can verify the fluentd is working as expected
```
$ docker logs -f docker_fluentd_1
2019-05-04 15:00:09 +0000 [info]: parsing config file is succeeded path="/fluentd/etc/fluent.conf"
2019-05-04 15:00:09 +0000 [warn]: To prevent events traffic jam, you should specify 2 or more 'flush_thread_count'.
2019-05-04 15:00:09 +0000 [info]: using configuration file: <ROOT>
  <source>
    @type tail
    path "/var/log/nginx/access.log"
    pos_file "/tmp/access.log.pos"
    tag "nginx.access"
    <parse>
      @type "nginx"
    </parse>
  </source>
  <match nginx.access>
    @type copy
    <store>
      @type "stdout"
    </store>
    <store>
      @type "elasticsearch"
      host "elasticsearch"
      port 9200
      logstash_format true
      logstash_prefix "fluentd"
      logstash_dateformat "%Y%m%d"
      type_name "accesslogs"
    </store>
  </match>
</ROOT>
2019-05-04 15:00:09 +0000 [info]: starting fluentd-1.4.2 pid=11 ruby="2.5.3"
2019-05-04 15:00:09 +0000 [info]: spawn command to main:  cmdline=["/usr/bin/ruby", "-Eascii-8bit:ascii-8bit", "/usr/bin/fluentd", "-c", "/fluentd/etc/fluent.conf", "-p", "/fluentd/plugins", "--under-supervisor"]
2019-05-04 15:00:10 +0000 [info]: gem 'fluent-plugin-elasticsearch' version '3.4.3'
2019-05-04 15:00:10 +0000 [info]: gem 'fluentd' version '1.4.2'
2019-05-04 15:00:10 +0000 [info]: adding match pattern="nginx.access" type="copy"
2019-05-04 15:00:12 +0000 [warn]: #0 Could not communicate to Elasticsearch, resetting connection and trying again. Connection refused - connect(2) for 172.29.0.4:9200 (Errno::ECONNREFUSED)
2019-05-04 15:00:16 +0000 [warn]: #0 Could not communicate to Elasticsearch, resetting connection and trying again. Connection refused - connect(2) for 172.29.0.4:9200 (Errno::ECONNREFUSED)
2019-05-04 15:00:24 +0000 [warn]: #0 Could not communicate to Elasticsearch, resetting connection and trying again. Connection refused - connect(2) for 172.29.0.4:9200 (Errno::ECONNREFUSED)
2019-05-04 15:00:24 +0000 [warn]: #0 Detected ES 7.x or above: `_doc` will be used as the document `_type`.
2019-05-04 15:00:24 +0000 [warn]: #0 To prevent events traffic jam, you should specify 2 or more 'flush_thread_count'.
2019-05-04 15:00:24 +0000 [info]: adding source type="tail"
2019-05-04 15:00:24 +0000 [info]: #0 starting fluentd worker pid=19 ppid=11 worker=0
2019-05-04 15:00:24 +0000 [info]: #0 following tail of /var/log/nginx/access.log
2019-05-04 15:00:24 +0000 [info]: #0 fluentd worker is now running worker=0
2019-05-04 15:42:55.000000000 +0000 nginx.access: {"remote":"10.0.2.2","host":"-","user":"-","method":"GET","path":"/","code":"200","size":"123211","referer":"-","agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36"}
```

## elasticsearch
if you want to know elasticsearch is up and running, you can check:
```
$ curl http://localhost:9200
{
  "name" : "7a2e3065db25",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "r2sHsjDXRhGjaSCja5G2Ww",
  "version" : {
    "number" : "7.0.0",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "b7e28a7",
    "build_date" : "2019-04-05T22:55:32.697037Z",
    "build_snapshot" : false,
    "lucene_version" : "8.0.0",
    "minimum_wire_compatibility_version" : "6.7.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
fluentd logs are transfered to the elasticsearch, and there will be fluentd index automatically generated  
you can check what the index name is, in docker/containers/fluentd/fluent.conf:  
`logstash_prefix fluentd`
after about 1 miniutes after the fluentd send the logs to elasticsearch,  
there will be fluentd index:  
```
$ curl http://localhost:9200/_cat/indices
green  open .kibana_1            ZF3AsI1DQMm20cpUQMJ6zw 1 0 2 0  7.8kb  7.8kb
yellow open fluentd-20190504     CVOCJ2w7SWCwyTNi4P9RVw 1 1 2 0  9.2kb  9.2kb
green  open .kibana_task_manager JOUAqtmyTiC83v5FHUPgyQ 1 0 2 0 45.5kb 45.5kb
```

## kibana
### check kibana is runnning
http://localhost:5601

### Step 1 of 2: Define index pattern
set up index pattern for fluentd logs  
http://localhost:5601/app/kibana#/management/kibana/index_pattern  
you need to designate the index pattern to match fluentd logs  
`fluentd-*`
the following is the index pattern page:
```
Step 1 of 2: Define index pattern
Index pattern
fluentd-*
You can use a * as a wildcard in your index pattern.

You can't use spaces or the characters \, /, ?, ", <, >, |.


Next step
 Success! Your index pattern matches 1 index.
fluentd-20190504
```
### Step 2 of 2: Configure settings
select Time Filter field name  
`@timestamp`
and create index pattern

### see the time series logs and visual graph
http://localhost:5601/app/kibana#/discover  
you need to wait for about 1 miniute to be visualized after you access the https://localhost/

## prometheus
http://localhost:9090

you can see the target list for collect resource data:  
http://localhost:9090/targets

```
Targets

docker (1/1 up)
Endpoint	State	Labels	Last Scrape	Scrape Duration	Error
http://cadvisor:8080/metrics
UP	group="docker-container" instance="cadvisor:8080" job="docker"	5.528s ago	59.05ms
node (1/1 up)
Endpoint	State	Labels	Last Scrape	Scrape Duration	Error
http://node_exporter:9100/metrics
UP	group="docker-host" instance="node_exporter:9100" job="node"	7.627s ago	13.33ms
prometheus (1/1 up)
Endpoint	State	Labels	Last Scrape	Scrape Duration	Error
http://127.0.0.1:9090/metrics
UP	instance="127.0.0.1:9090" job="prometheus"	3.338s ago	5.314ms
```

* cadvisor gather all container metrics automatically
* node_exporter gather the docker host metrics
* 127.0.0.1:9090 instance is prometheus itself

## grafana
http://localhost:3000

you can login to the basic authentication defined in docker-compose.yml  
```
     environment:
       GF_SECURITY_ADMIN_USER: yourname
       GF_SECURITY_ADMIN_PASSWORD: password
```

### add datasource
http://localhost:3000/datasources/new?gettingstarted  
1. chose prometheus
2. in the HTTP section, URL: http://prometheus:9090
docker automatically add docker service name to the name resolver in the docker network  
so you can access from the grafana container to prometheus container using the service name: prometheus  

### import dashboard
http://localhost:3000/dashboard/import

you can search https://grafana.com/dashboards for dashboard already created by users  

I recommend 893, 179 for docker-host and docker-container monitoring

***
that's all!
Enjoy!

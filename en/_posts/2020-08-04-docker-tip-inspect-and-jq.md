---
layout: flexstart-blog-single
title: "Docker tip : inspect and jq"
author: Full
featured: true
lang: en
ref: inspectjq_1244
categories:
  - docker
date: 2021-12-15T09:32:28.972Z
image: https://res.cloudinary.com/brightsoftwares/image/upload/v1639560797/photo-1578403881636-6f4a77a6f9cc_ddsft1.jpg
description: This isn’t so much a docker tip, as it is a jq tip. If you haven’t
  heard of jq, it is a great tool for parsing JSON from the command line. This
  also makes it a great tool to see what is happening in a container instead of
  having to use the –format specifier which I can never remember how to use
  exactly
---
# Docker inspect and jq

This isn’t so much a docker tip, as it is a jq tip. If you haven’t heard of jq, it is a great tool for parsing JSON from the command line. This also makes it a great tool to see what is happening in a container instead of having to use the ```–format``` specifier which I can never remember how to use exactly:

## Get network information:

{% include codeHeader.html %}
{% raw %}
```
    $ docker inspect 4c45aea49180 | jq '.[].NetworkSettings.Networks'
```
{% endraw %}


The output is:

{% raw %}
```
    {
      "bridge": {
        "EndpointID": "ba1b6efba16de99f260e0fa8892fd4685dbe2f79cba37ac0114195e9fad66075",
        "Gateway": "172.17.0.1",
        "IPAddress": "172.17.0.2",
        "IPPrefixLen": 16,
        "IPv6Gateway": "",
        "GlobalIPv6Address": "",
        "GlobalIPv6PrefixLen": 0,
        "MacAddress": "02:42:ac:11:00:02"
      }
    }
    
```
{% endraw %}
   
 
## Get the arguments with which the container was started

{% include codeHeader.html %}
{% raw %}
```
    $ docker inspect 4c45aea49180 | jq '.[].Args'
```
{% endraw %}    

The output is:

{% raw %}
```
    [
    "-server",
    "-advertise",
    "192.168.99.100",
    "-bootstrap-expect",
    "1"
    ]
```
{% endraw %}
    
    
## Get all the mounted volumes
    
{% include codeHeader.html %}
{% raw %}
```
$ docker inspect 4c45aea49180 | jq '.[].Mounts'
```
{% endraw %}

Output


{% raw %}
```

    [
    {
    "Name": "a8125ffdf6c4be1db4464345ba36b0417a18aaa3a025267596e292249ca4391f",
    "Source": "/mnt/sda1/var/lib/docker/volumes/a8125ffdf6c4be1db4464345ba36b0417a18aaa3a025267596e292249ca4391f/_data",
    "Destination": "/data",
    "Driver": "local",
    "Mode": "",
    "RW": true
    }
    ]
```
{% endraw %}

    

And of course also works great for querying other kinds of (docker-esque) APIs that produce JSON (e.g Marathon, Mesos, Consul etc.). JQ provides a very extensive API for accessing and processing JSON. More information can be found here: https://stedolan.github.io/jq/
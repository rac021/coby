#!/bin/bash

docker run -it --net host                                                \
           --memory-swappiness=0                                         \
            --ulimit nproc=20000:50000                                   \
           -v `pwd`/src/orchestrators/.:/opt/coby/pipeline/orchestrators \
           -v `pwd`/src/SI:/opt/coby/pipeline/SI coby                    \
           /opt/coby/pipeline/orchestrators/synthesis_extractor_entry.sh



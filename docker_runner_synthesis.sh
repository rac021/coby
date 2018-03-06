#!/bin/bash

docker run -it --net host                                                \
           --memory-swap=0                                               \
           --memory-swappiness=0                                         \
           -v `pwd`/src/orchestrators/.:/opt/coby/pipeline/orchestrators \
           -v `pwd`/src/SI:/opt/coby/pipeline/SI coby                    \
           /opt/coby/pipeline/orchestrators/synthesis_extractor_entry.sh



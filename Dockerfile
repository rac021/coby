
 FROM harisekhon/debian-java

 MAINTAINER Rac021 ( r.yahiaoui.21@gmail.com )

 USER root

 RUN echo " ** Update Distrib "                  && \
     echo " "                                    && \
     echo "root:root_pass" | chpasswd            && \
     adduser --disabled-password --gecos '' coby && \
     echo "coby:coby_pass" | chpasswd            && \
     apt-get -y update                           && \
     apt-get -y install procps                   && \
     apt-get -y install curl                     && \
     apt-get clean  

 RUN mkdir /opt/coby

 COPY coby_bin/. /opt/coby

 RUN chown -R coby:coby /opt/coby/

 RUN chmod -R 777 /opt/coby/

 USER coby 

 WORKDIR /opt/coby

 CMD /bin/bash

 

FROM ubuntu:bionic
RUN useradd -u 555 dockerapp\
    && mkdir /home/dockerapp\
    && mkdir /home/dockerapp/app \
    && mkdir /home/dockerapp/data \
    && mkdir /home/dockerapp/cashe \
    && mkdir /home/dockerapp/deleted \
    && chown -R dockerapp:dockerapp /home/dockerapp  \
    && addgroup dockerapp staff
	
RUN apt-get update \
	&& apt install -y locales \	
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt install -y --no-install-recommends \
	apt-utils \
	ca-certificates \
	curl \
        wget \
	&& rm -rf /var/lib/apt/lists/*

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libxml2-dev \
    gdebi \
    libssl-dev \
    systemd \
    zip \
    unzip

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev \
    gfortran \
    aptitude \
    libgdal-dev \
    libproj-dev \
    g++ \
    libicu-dev \
    libpcre3-dev\
    libbz2-dev \
    liblzma-dev \
    libnlopt-dev \
    build-essential \
    uchardet libuchardet-dev \
    task-spooler \
    cmake \
    cron \
    git-core
    
WORKDIR /home/docker
RUN sudo wget https://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN sudo dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb 
# Download, valiate, and unpack and install Micrisift R open
RUN wget https://www.dropbox.com/s/uz4e4d0frk21cvn/microsoft-r-open-3.5.1.tar.gz?dl=1 -O microsoft-r-open-3.5.1.tar.gz \
&& echo "9791AAFB94844544930A1D896F2BF1404205DBF2EC059C51AE75EBB3A31B3792 microsoft-r-open-3.5.1.tar.gz" > checksum.txt \
	&& sha256sum -c --strict checksum.txt \
	&& tar -xf microsoft-r-open-3.5.1.tar.gz \
	&& cd /home/docker/microsoft-r-open \
	&& ./install.sh -a -u \
	&& ls logs && cat logs/*


# Clean up
WORKDIR /home/docker
RUN rm microsoft-r-open-3.5.1.tar.gz \
	&& rm checksum.txt \
&& rm -r microsoft-r-open



# basic shiny functionality
RUN sudo R -e "install.packages('rmarkdown', repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shiny'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shinyjs'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shinythemes'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('dplyr'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('data.table'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('remotes'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('ggplot2'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('deSolve'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('quantmod'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('ggthemes'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('highcharter'), repos='https://cran.amrcloud.net/')" \
&& R -e "install.packages(c('shinyWidgets'), repos='https://cran.amrcloud.net/')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); remotes::install_github('JohnCoene/waiter')\"" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); remotes::install_github('dreamRs/shinybusy')\"" 

VOLUME /home/dockerapp/app
EXPOSE 3838
USER dockerapp

CMD ["R", "-e shiny::runApp('/home/dockerapp/app',port=3838,host='0.0.0.0')"]

FROM ubuntu:18.04
USER root

ENV BRANCH master

EXPOSE 3000

# Install dependencies
RUN apt-get update
RUN apt-get install -y build-essential git curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

#Get application code
RUN git clone https://github.com/andreyyec/application.git timeoff-management

WORKDIR /timeoff-management/

#build and deploy
RUN npm install

COPY ./scripts/entrypoint.sh /
RUN chmod 775 /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

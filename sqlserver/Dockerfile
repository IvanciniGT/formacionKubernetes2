
FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update --fix-missing && \
    apt-get install -y gnupg2 && \
    apt-get install -yq curl apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | tac | tac | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list | tac | tac | tee /etc/apt/sources.list.d/mssql-server.list && \
    apt-get update

RUN apt-get install -y mssql-server-fts

CMD /opt/mssql/bin/sqlservr
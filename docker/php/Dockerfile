# ========== stage to build awsiot_mqtt ==========
FROM golang:1.21.2 as awsiot_mqtt_builder

WORKDIR /awsiot_mqtt

COPY cmd/awsiot_mqtt/go.mod cmd/awsiot_mqtt/go.sum ./
RUN go mod download && go mod tidy

COPY cmd/awsiot_mqtt/ ./

RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64 make build OUT='awsiot_mqtt'

# ========== statge to build php ==========
FROM php:8.2-apache

WORKDIR /var/www/html/php_queue

# install packages
RUN apt-get update -qq && apt-get install -y curl sqlite3 libsqlite3-dev

# install cputil
ARG CPUTIL_BINARY_DL_URL_BASE
ARG CPUTIL_BINARY_NAME
RUN mkdir -p /opt/starmicronics/cputil &&\
  mkdir /opt/starmicronics/tmp &&\
  curl -o /opt/starmicronics/tmp/${CPUTIL_BINARY_NAME} ${CPUTIL_BINARY_DL_URL_BASE}${CPUTIL_BINARY_NAME} &&\
  tar -zxvf /opt/starmicronics/tmp/${CPUTIL_BINARY_NAME} -C /opt/starmicronics/cputil/ &&\
  rm -rf /opt/starmicronics/tmp &&\
  chmod 755 /opt/starmicronics/cputil/cputil-linux-x64/cputil &&\
  ln -s /opt/starmicronics/cputil/cputil-linux-x64/cputil /usr/local/bin/cputil

# setup awsiot_mqtt
COPY --from=awsiot_mqtt_builder /awsiot_mqtt/awsiot_mqtt /usr/local/bin/awsiot_mqtt

# add user and group
ARG GROUP_ID
ARG GROUP_NAME
ARG USER_ID
ARG USER_NAME
RUN groupadd -f -g ${GROUP_ID} ${GROUP_NAME}
RUN if getent passwd ${USER_NAME} > /dev/null; then\
      usermod -s /bin/bash -g ${GROUP_NAME} ${USER_NAME};\
    else\
      useradd -m -o -s /bin/bash -u ${USER_ID} -g ${GROUP_NAME} ${USER_NAME};\
    fi

# chage owner
RUN chown -R ${USER_NAME}:${GROUP_NAME} .

# set user
USER ${USER_NAME}

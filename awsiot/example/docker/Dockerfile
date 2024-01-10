FROM ubuntu:jammy

RUN apt-get update -qq && apt-get install -y curl jq less sed unzip zip

WORKDIR /tmp
ARG AWS_CLI_INSTALLER_NAME
RUN curl "https://awscli.amazonaws.com/${AWS_CLI_INSTALLER_NAME}" -o "awscliv2.zip" &&\
  unzip awscliv2.zip &&\
  ./aws/install &&\
  rm -rf awscliv2.zip aws

WORKDIR /awsiot

COPY awscli/ ./awscli/

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

CMD [ "bash" ]

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM openjdk:8-alpine
LABEL maintainer="Presto community <https://prestosql.io/community.html>"

ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV PRESTO_HOME /presto
ENV PRESTO_USER presto
ENV PRESTO_CONF_DIR ${PRESTO_HOME}/etc
ENV PATH $PATH:$PRESTO_HOME/bin

RUN \
    set -xeu && \
    apk add --no-cache bash && \
    apk add --no-cache python && \
    apk add --no-cache curl && \
    mkdir -p ${PRESTO_HOME} ${PRESTO_HOME}/data && \
    addgroup -g 1000 presto  && \
    adduser -D -u 1000 -h ${PRESTO_HOME} -s /bin/bash -G $PRESTO_USER $PRESTO_USER && \
    chown -R ${PRESTO_USER}:${PRESTO_USER} $PRESTO_HOME

ARG PRESTO_VERSION
COPY presto-cli-${PRESTO_VERSION}-executable.jar $PRESTO_HOME/bin/presto
COPY --chown=presto:presto presto-server-${PRESTO_VERSION}/ $PRESTO_HOME/

EXPOSE 8080
USER $PRESTO_USER

CMD ["launcher", "run"]

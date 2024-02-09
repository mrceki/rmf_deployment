ARG BUILDER_NS="rmf-hamal/rmf_deployment"
ARG TAG="latest"

FROM $BUILDER_NS/builder-rmf-web:$TAG

SHELL ["bash", "-c"]

ENV RMF_SERVER_USE_SIM_TIME=true

RUN . /opt/rmf/install/setup.bash && \
  cd /opt/rmf/src/rmf-web/packages/api-server && \
  pnpm run prepack

FROM $BUILDER_NS/builder-rmf-web:$TAG

COPY --from=0 /opt/rmf/src/rmf-web/packages/api-server/dist/ .

SHELL ["bash", "-c"]
RUN pip3 install $(ls -1 | grep '.*.whl')[postgres]
RUN pip3 install tortoise-orm

# cleanup
RUN rm -rf /opt/rmf/src
RUN rm -rf /var/lib/apt/lists && \
  pnpm store prune

RUN echo -e '#!/bin/bash\n\
  . /opt/rmf/install/setup.bash\n\ 
  exec rmf_api_server "$@"\n\
  ' > /docker-entry-point.sh && chmod +x /docker-entry-point.sh

ENTRYPOINT ["/docker-entry-point.sh"]

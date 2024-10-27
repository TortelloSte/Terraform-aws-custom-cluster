# Usa l'immagine di base curl con sh
FROM curlimages/curl:latest

# Passa all'utente root per installare i pacchetti
USER root

# Installa jq usando apk (per Alpine Linux)
RUN apk update && apk add jq

# Copia lo script nel container
COPY ./scripts/retrieve-data.sh /scripts/retrieve-data.sh

# Rendi eseguibile lo script
RUN chmod +x /scripts/retrieve-data.sh

# Definisci il comando di default per eseguire lo script
CMD ["/scripts/retrieve-data.sh"]
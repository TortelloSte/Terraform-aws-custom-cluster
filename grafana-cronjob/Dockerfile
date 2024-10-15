# Usa l'immagine di base curl con sh
FROM curlimages/curl:latest

# Passa all'utente root per installare i pacchetti
USER root

# Installa jq
RUN apk add --no-cache jq

# Copia lo script nel container
COPY ./scripts/retrieve-data.sh /scripts/retrieve-data.sh

# Rendi eseguibile lo script
RUN chmod +x /scripts/retrieve-data.sh

# Definisci il comando di default
CMD ["/bin/sh"]

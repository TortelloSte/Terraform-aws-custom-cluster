#!/bin/sh

# Imposta l'UID della dashboard "test"
DASHBOARD_UID="your_dashboard_uid_here"

mkdir -p /data/Log  # Crea la cartella Log
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")  # Crea un timestamp per il nome del file

# Scarica la configurazione della dashboard chiamata "test"
dashboard_data=$(curl -G -H "Authorization: Bearer $GRAFANA_API_KEY" "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID")

# Filtra la dashboard con il titolo "test" e accedi alla sezione "Host Overview"
host_overview=$(echo $dashboard_data | jq '.dashboard.panels[] | select(.title == "Host Overview")')

# Recupera i pannelli presenti nella sezione "Host Overview"
panels=$(echo $host_overview | jq '.panels[]')

# Inizializza il file di log
echo "Pannelli presenti nella dashboard 'Host Overview':" > /data/Log/grafana_data_$timestamp.log

# Aggiunge i valori di tutti e 14 i pannelli nel file di log
for panel in $(echo "$panels" | jq -c '.'); do
    echo $panel >> /data/Log/grafana_data_$timestamp.log
done

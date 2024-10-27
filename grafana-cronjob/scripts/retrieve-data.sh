#!/bin/sh

# Imposta l'UID della dashboard "test"
DASHBOARD_UID="ce0uvccdzabk0a"  # Verifica che sia corretto
GRAFANA_API_KEY="sa-1-test-720be7b8-d3e3-491d-95c6-2fb077105443"
GRAFANA_URL="http://my-monitoring-grafana.default.svc.cluster.local"

# Fai una chiamata curl all'API di Grafana per ottenere i dati della dashboard
dashboard_data=$(curl -s -G -H "Authorization: Bearer $GRAFANA_API_KEY" "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID")

# Verifica che la chiamata curl abbia avuto successo
if [ $? -ne 0 ]; then
    echo "Errore durante la richiesta a Grafana API."
    exit 1
fi

# Controlla se dashboard_data è vuoto o se ci sono errori
if [ -z "$dashboard_data" ]; then
    echo "Errore: Nessun dato restituito dalla dashboard con UID $DASHBOARD_UID."
    exit 1
fi

# Usa jq per trovare il pannello con il titolo "CPU"
cpu_panel=$(echo "$dashboard_data" | jq '.dashboard.panels[] | select(.title == "CPU")')

# Verifica se il pannello è stato trovato
if [ -z "$cpu_panel" ]; then
    echo "Nessun pannello trovato con il titolo 'CPU'"
    exit 1
fi

# Stampa i dettagli del pannello CPU
echo "Pannello CPU trovato:"
echo "$cpu_panel"

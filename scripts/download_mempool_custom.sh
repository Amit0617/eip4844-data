
#!/bin/bash

# Fetch arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --date-range)
            DATE_RANGE="$2"
            shift; shift
            ;;
        --hour-range)
            HOUR_RANGE="$2"
            shift; shift
            ;;
        *)
            shift
            ;;
    esac
done

DOMAIN="https://archive.blocknative.com/"
SUCCESSFUL_DOWNLOADS=0

download_data() {
    local DATE=$1
    local HOUR_START=$2
    local HOUR_END=$3
    local BASE_URL="${DOMAIN}${DATE}/"

    for HOUR in $(seq -w $HOUR_START $HOUR_END); do
        URL="${BASE_URL}${HOUR}.csv.gz"
        FILENAME="${DATE}_${HOUR}.csv.gz"
        RETRIES=0

        while true; do
            HTTP_STATUS=$(curl -o "$FILENAME" -w "%{http_code}" "$URL")

            if [ "$HTTP_STATUS" -eq 200 ]; then
                echo "Downloaded $FILENAME"
                ((SUCCESSFUL_DOWNLOADS++))
                break
            elif [ "$HTTP_STATUS" -eq 429 ] || [ "$HTTP_STATUS" -eq 504 ]; then
                echo "Received $HTTP_STATUS. Retrying in 1 second..."
                sleep 1
                ((RETRIES++))
                if [ $RETRIES -ge 3 ]; then
                    echo "Retry limit reached. Exiting."
                    exit 1
                fi
            elif [ "$HTTP_STATUS" -eq 404 ]; then
                echo "File not found (404). Exiting for $FILENAME."
                break
            else
                echo "Error downloading $FILENAME - Status code: $HTTP_STATUS"
                rm "$FILENAME"
                break
            fi
        done
    done
}

# Date Range Mode
if [ ! -z "$DATE_RANGE" ]; then
    IFS='-' read -ra DATES <<< "$DATE_RANGE"
    START_DATE=${DATES[0]}
    END_DATE=${DATES[1]}

    for DATE in $(seq -w $START_DATE $END_DATE); do
        download_data $DATE 00 23
    done
fi

# Hour Range Mode
if [ ! -z "$HOUR_RANGE" ]; then
    IFS=':' read -ra PARTS <<< "$HOUR_RANGE"
    DATE=${PARTS[0]}
    IFS='-' read -ra HOURS <<< "${PARTS[1]}"
    HOUR_START=${HOURS[0]}
    HOUR_END=${HOURS[1]}

    download_data $DATE $HOUR_START $HOUR_END
fi

if [ "$SUCCESSFUL_DOWNLOADS" -gt 0 ]; then
    echo "All slices downloaded successfully!"
else
    echo "Some slices were not downloaded successfully."
fi

#!/bin/bash

# Set the date
DATE="YYYYMMDD"
DOMAIN="https://archive.blocknative.com/"
BASE_URL="${DOMAIN}${DATE}/"

# Initialize a variable to track successful downloads
SUCCESSFUL_DOWNLOADS=0

# Loop through each hour (00 to 23)
for HOUR in {00..23}; do
    # Construct the URL for the current hour's data
    URL="${BASE_URL}${HOUR}.csv.gz"

    # Define the filename for the current hour's data
    FILENAME="${HOUR}.csv.gz"

    # Initialize a variable to keep track of retries
    RETRIES=0

    # Loop to handle retries on 404, 429, and 504 responses
    while true; do
        # Download the data and check the response status code
        HTTP_STATUS=$(curl -o "$FILENAME" -w "%{http_code}" "$URL")

        # Check the status code and print a message
        if [ "$HTTP_STATUS" -eq 200 ]; then
            echo "Downloaded $FILENAME"
            ((SUCCESSFUL_DOWNLOADS++))
            break  # Exit the retry loop on success
        elif [ "$HTTP_STATUS" -eq 429 ] || [ "$HTTP_STATUS" -eq 504 ]; then
            echo "Received $HTTP_STATUS. Retrying in 1 second..."
            sleep 1  # Wait for 1 second before retrying
            ((RETRIES++))
            if [ $RETRIES -ge 3 ]; then
                echo "Retry limit reached. Exiting."
                exit 1
            fi
        elif [ "$HTTP_STATUS" -eq 404 ]; then
            echo "File not found (404). Exiting for $FILENAME."
            break  # Exit the retry loop for 404
        else
            echo "Error downloading $FILENAME - Status code: $HTTP_STATUS"
            rm "$FILENAME"  # Remove the empty file
            break  # Exit the retry loop on other errors
        fi
    done
done

if [ "$SUCCESSFUL_DOWNLOADS" -eq 24 ]; then
    echo "All slices downloaded successfully!"
else
    echo "Some slices were not downloaded successfully."
fi

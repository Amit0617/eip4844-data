# A script to find all transactions with timepending = 0 and status = 'confirmed' and blobversionedhashes is not Null
import csv
import pandas as pd

# Check all the csv files in the current directory
import os
directory = '../data' # github action's working directory is scripts directory
for filename in os.listdir(directory):
    with open(f'{directory}/private-transactions.csv', 'a') as file:
        if filename.endswith(".csv"):
            print(filename)
            df = pd.read_csv(f'{directory}/{filename}')
            # Filter the data
            df = df[(df['timepending'] == 0) & (df['status'] == 'confirmed') & (df['blobversionedhashes'].notnull())]
            # Save the filtered data
            df.to_csv(file, index=False)
        else:
            continue
print('Done!')
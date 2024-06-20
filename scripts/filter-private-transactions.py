# A script to find all transactions with timepending = 0 and status = 'confirmed' and blobversionedhashes is not Null
import csv
import pandas as pd
import traceback

# Check all the csv files in the current directory
import os
directory = '../data' # github action's working directory is scripts directory
for filename in os.listdir(directory):
    with open(f'{directory}/private-transactions.csv', 'a') as file:
        if filename.endswith(".csv") and filename != 'private-transactions.csv':
            print(filename)
            try:
                df = pd.read_csv(f'{directory}/{filename}', sep='\t')
                # Filter the data
                # if blobversionedhashes column exists
                if 'blobversionedhashes' not in df.columns:
                    df = df[(df['timepending'] == 0) & (df['status'] == 'confirmed')]
                else:
                    df = df[(df['timepending'] == 0) & (df['status'] == 'confirmed') & (df['blobversionedhashes'].notnull())]
                # Save the filtered data
                df.to_csv(file, index=False)
            except:
                print(f'Error in {filename}')
                # print the error
                print(traceback.format_exc())
                # Skip the line if there is an error
                continue
        else:
            continue
print('Done!')
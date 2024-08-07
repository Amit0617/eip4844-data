# A script to find all transactions with timepending = 0 and status = 'confirmed' and blobversionedhashes is not Null
import csv
import pandas as pd
import traceback
import os

# Check all the csv files in the current directory
directory = '../data' # github action's working directory is scripts directory
for filename in os.listdir(directory):
    with open(f'{directory}/private-transactions2.csv', 'a') as file:
        if filename.endswith(".csv") and filename != 'private-transactions.csv' and filename != 'private-transactions2.csv':
            print(filename)
            try:
                df = pd.read_csv(f'{directory}/{filename}', sep='\t')
                # Filter the data
                # if blobversionedhashes column exists
                if 'blobversionedhashes' not in df.columns:
                    df = df[(df['timepending'] == 0) & (df['status'] == 'confirmed')]
                else:
                    df = df[(df['timepending'] == 0) & (df['status'] == 'confirmed') & (df['blobversionedhashes'].notna())]
                # Save the filtered data without header
                df.to_csv(file, index=False, header=False)
            except:
                print(f'Error in {filename}')
                # print the error
                print(traceback.format_exc())
                # Skip the line if there is an error
                continue
        else:
            continue

# Read the created csv file and update README.md for plotting chart
print("Reading the created csv file")
df = pd.read_csv(f'{directory}/private-transactions2.csv')
# number of transactions per day
transactions_per_day = df['detect_date'].value_counts().sort_index()
# unique dates
dates = transactions_per_day.index
# divide dates into separate months array
months = []
for date in dates:
    if date.split('-')[1] not in months:
        months.append(date.split('-')[1])

print("Writing to README.md")
with open(f'../README.md', 'w') as readme:
    # number of transactions per day in the README.md for creating mermaid xy chart
    for month in months:
        # print(f"Month: {month}")
        month_dates = [date for date in dates if date.split('-')[1] == month]
        # print(month_dates)
        readme.write('```mermaid\n')
        # configs for the chart
        readme.write('---\n')
        readme.write('config:\n')
        readme.write('    xyChart:\n')
        readme.write('        width: ' + str(len(month_dates) * 80) + '\n')     # width of the chart should be dates length * 80 for no overlapping
        readme.write('        height: 600\n')
        readme.write('---\n')
        # chart data
        readme.write(f'xychart-beta title "Number of private blob transactions per day in {month}th month"\n')
        readme.write('x-axis "Date" [' + ','.join([str(date) for date in month_dates]) + ']' + '\n')
        readme.write('y-axis "Number of Transactions"\n')
        # split the transactions per day into separate arrays for each month
        tx_per_day = [transactions_per_day[date] for date in month_dates]
        readme.write('bar[' + ','.join([str(tx_count) for tx_count in tx_per_day]) + ']' + '\n')
        readme.write('```\n\n')
import pandas as pd

def lambda_handler(event, context):

    lst = ['row1', 'row2', 'row3', 'row4']

    df = pd.DataFrame(lst)
    print(df.head())
    
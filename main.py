import pandas as pd


def import_data():
    data = pd.read_excel('products.xlsx')
    return data


def summary_statistics():
    data = import_data()
    data_private = data[data.PrivateLabelInd == True]
    data_brands = data[data.PrivateLabelInd == True]

    summary_data = data.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()
    summary_data_private = data_private.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()
    summary_data_brands = data_brands.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()

    summary_data.to_csv('summary_stats.csv', index=True)
    summary_data_private.to_csv('summary_stats_private.csv', index=True)
    summary_data_brands.to_csv('summary_stats_brands.csv', index=True)


if __name__ == '__main__':
    summary_statistics()


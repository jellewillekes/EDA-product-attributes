import pandas as pd
import matplotlib.pyplot as plt

def import_data():
    data = pd.read_excel('products.xlsx')
    return data


def summary_statistics(files=False):
    data = import_data()
    data_private = data[data.PrivateLabelInd == True]
    data_brands = data[data.PrivateLabelInd == True]

    summary_data = data.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()
    summary_data_private = data_private.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()
    summary_data_brands = data_brands.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()

    if files==True:
        summary_data.to_csv('summary_stats.csv', index=True)
        summary_data_private.to_csv('summary_stats_private.csv', index=True)
        summary_data_brands.to_csv('summary_stats_brands.csv', index=True)

    brand_category = data.groupby('Category')['Brand'].nunique()
    products_total = data['ItemDescr'].nunique()
    product_category = data.groupby('Category')['ItemDescr'].nunique()

    axes_labels = data.groupby(['PeriodKey']).groups.keys()

    fig, ax = plt.subplots(figsize=(15, 7))
    data.groupby(['Category', 'PeriodKey'])['QuantityCE'].plot(ax=ax, legend=True)
    plt.show()


if __name__ == '__main__':
    summary_statistics()


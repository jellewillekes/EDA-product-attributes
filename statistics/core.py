import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(color_codes = True)


def summary_statistics(data):
    data_private = data[data.PrivateLabel==True]
    data_brands = data[data.PrivateLabel==True]

    data_soda = data.loc[data['Category'] == 'Frisdranken en Houdbaar Sap']
    data_juice = data.loc[data['Category'] == 'Fruit en Verse Sappen']
    data_dairy = data.loc[data['Category'] == 'Zuivel en Gekoeld Sap']
    data_meat = data.loc[data['Category'] == 'Gevogelte en Vis Vega']

    fig, ax = plt.subplots(figsize=(15, 7))
    data_soda['QuantityCE'].plot(ax=ax, legend=True)

    plt.figure(figsize=(20, 10))
    c = round(data, 3).corr()
    c.to_csv('attributes_corr.csv', index=False)
    sns.heatmap(c)
    plt.savefig('attributes_corr.png', dpi=400)

    summary_data = data.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()
    summary_data_private = data_private.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()
    summary_data_brands = data_brands.groupby(by=['Category', 'PeriodKey'], dropna=False).describe()

    summary_data.to_csv('../results/summary_stats.csv', index=True)
    summary_data_private.to_csv('../results/summary_stats_private.csv', index=True)
    summary_data_brands.to_csv('../results/summary_stats_brands.csv', index=True)

    brand_category = data.groupby('Category')['Brand'].nunique()
    products_total = data['ItemDescr'].nunique()
    product_category = data.groupby('Category')['ItemDescr'].nunique()

    axes_labels = data.groupby(['PeriodKey']).groups.keys()

    fig, ax = plt.subplots(figsize=(15, 7))
    data.groupby(['Category', 'PeriodKey'])['QuantityCE'].plot(ax=ax, legend=True)
    plt.show()
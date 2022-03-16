import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.datasets import load_boston
from upsetplot import UpSet


def exploratory_analysis(data):
    # Check data types:
    print(data.dtypes)
    data.dtypes
    data.dtypes.to_csv('../results/dtypes.csv')
    # Check data completeness:
    print(data.count())
    variables_null = data.isnull().sum()
    data_null = data.loc[(data['PeriodKey'].isnull() & data['QuantityCE'].isnull() & data['SalesGoodsEUR'].isnull())]
    """Most of the categories/variables have 2759 elements, except 'PeriodKey' (2757), 'QuantityCE' (2757) and 
    'SalesGoodsEUR' (2757). 'StandardWeight' (191) reports many NaN values. There are no duplicate rows. 
    AH Slagroom 250 gram and AH Blauwe bessen 500 gram have a missing PeriodKey"""
    label_count = data.groupby(['ItemDescr']).count()

    item_descr = data['ItemDescr'].unique()

    # Adjust RetailItemPrice for content size. All products in 1KG, 1L or 1ST
    data['PriceAdjusted'] = np.where(data['UOM'] == 'LT', data['RetailItemPrice'] / data['Content'],
                                     np.where(data['UOM'] == 'KG', data['RetailItemPrice'] / data['Content'],
                                              np.where(data['UOM'] == 'GR',
                                                       data['RetailItemPrice'] / data['Content'] * 1000,
                                                       np.where(data['UOM'] == 'ML',
                                                                data['RetailItemPrice'] / data['Content'] * 1000,
                                                                np.where(data['UOM'] == 'LT',
                                                                         data['RetailItemPrice'] / data['Content'],
                                                                         data['RetailItemPrice'])))))
    data.to_csv('../data/products_adjusted.csv', index=True)

    data_product = data.groupby(['ItemDescr']).mean()
    product_category = data[['ItemDescr', 'Category']].drop_duplicates()
    data_product_category = data_product.merge(product_category, on='ItemDescr', how='left')

    # Create dataset with unique values and mean PriceAdjusted over periods:
    data_unique = data.drop(
        ['Content', 'UOM', 'PackagingType', 'Weight', 'RetailItemPrice', 'PeriodKey', 'QuantityCE', 'SalesGoodsEUR',
         'PriceAdjusted'], axis=1).drop_duplicates().sort_values(by=['ItemDescr'])
    price_unique = data.groupby(['ItemDescr'])['PriceAdjusted'].mean()
    sales_unique = data.groupby(['ItemDescr'])['SalesGoodsEUR'].mean()
    quantity_unique = data.groupby(['ItemDescr'])['QuantityCE'].mean()

    data_unique['QuantityCE'] = quantity_unique.to_list()
    data_unique['SalesGoodsEUR'] = sales_unique.to_list()
    data_unique['PriceAdjusted'] = price_unique.to_list()

    #Split data in Categories for further analysis:
    data_soda = data_unique.loc[data['Category'] == 'Soda']
    data_fruits = data_unique.loc[data['Category'] == 'Fruits']
    data_dairy = data_unique.loc[data['Category'] == 'Dairy']
    data_meat = data_unique.loc[data['Category'] == 'Meat']

    data_soda_sorted = data_soda.sort_values(['QuantityCE'], ascending=False)
    data_fruits_sorted = data_fruits.sort_values(['QuantityCE'], ascending=False)
    data_dairy_sorted = data_dairy.sort_values(['QuantityCE'], ascending=False)
    data_meat_sorted = data_meat.sort_values(['QuantityCE'], ascending=False)

    data_soda_sorted.to_csv('../data/soda_sorted.csv', index=True)
    data_fruits_sorted.to_csv('../data/fruits_sorted.csv', index=True)
    data_dairy_sorted.to_csv('../data/dairy_sorted.csv', index=True)
    data_meat_sorted.to_csv('../data/meat_sorted.csv', index=True)

    data = data.drop(['Content', 'UOM', 'PackagingType', 'Weight', 'RetailItemPrice'], axis=1)
    feature_names = ['Biological', 'PrivateLabel', 'LowFat', 'LowSalt', 'LowSugar', 'PlantBased', 'Vegan', 'Vegetarian',
                     'LocalProduct', 'HighFiber', 'WholeGrain', 'Glutenfree', 'Sustainable', 'Halal']

    corr = data.drop(['PeriodKey', 'Halal'], axis=1).corr()
    plt.figure(figsize=(12, 10))
    sns.heatmap(corr[(corr >= 0.2) | (corr <= -0.2)],
                cmap='vlag', vmax=1.0, vmin=-1.0, linewidths=0.1,
                annot=True, annot_kws={"size": 8}, square=True)
    plt.savefig('heatmap_corr.png')
    """Boxplotting Outliers"""
    # Detecting outliers (Multivariate Outlier Analysis):
    fig, ax = plt.subplots(1, 3, figsize=(10, 5))
    data_unique.boxplot('QuantityCE', 'Category', ax=ax[0])
    data_unique.boxplot('SalesGoodsEUR', 'Category', ax=ax[1])
    data_unique.boxplot('PriceAdjusted', 'Category', ax=ax[2])
    plt.savefig('../results/Boxplot.png')

    data_unique[['QuantityCE', 'SalesGoodsEUR', 'PriceAdjusted']].hist(bins=50)

    # Get five features most correlated with median house value
    correl_QuantityCE = data[feature_names].corrwith(pd.Series(data.QuantityCE),
                                 method='spearman').sort_values()

    """Plot Intersections, AdjustedPrice and QuantityCE for different label combinations"""
    # Delete HighFiber, WholeGrain and Halal, because label count < 3 for unique Products
    print(data_unique[feature_names].sum())
    plot_names = ['Biological', 'PrivateLabel', 'LowFat', 'LowSalt', 'LowSugar', 'PlantBased', 'Vegan', 'Vegetarian',
                     'LocalProduct', 'Glutenfree', 'Sustainable']

    #data_plot = data_unique.set_index(list(data_unique[plot_names]))
    #upset = UpSet(data_plot, subset_size='count')
    #upset.add_catplot(value='QuantityCE', kind='strip', color='blue')
    #upset.add_catplot(value='PriceAdjusted', kind='strip', color='black')
    #upset.plot()
    #plt.title("Label Intersection for Products")
    #plt.show()
    #plt.savefig('../results/upset.png')


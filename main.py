import pandas as pd
import statistics
import eda
import datetime


def summary_statistics():
    print(f"[CALC STATS][TIME - {datetime.datetime.now()}]")
    data = import_data()
    statistics.summary_statistics(data)


def exploratory_analysis():
    print(f"[EXP. ANALYSIS][TIME - {datetime.datetime.now()}]")
    data = import_data()
    eda.exploratory_analysis(data)


def import_data():
    data = pd.read_excel('../data/products.xlsx')
    data = data.rename(columns={'StandardWeight': 'Weight', 'Biologisch': 'Biological', 'PrivateLabelInd': 'PrivateLabel',
                         'Low_fat': 'LowFat', 'Low_Salt': 'LowSalt', 'Low_Sugar': 'LowSugar',
                         'Plant_based': 'PlantBased', 'ndLekkerUitNederland': 'LocalProduct',
                         'ndHighInFiber': 'HighFiber', 'ndWholeGrain': 'WholeGrain', 'Glutenvrij': 'Glutenfree',
                         'ndSustainableProduced': 'Sustainable'})

    data["Category"].replace(
        {"Frisdranken en Houdbaar Sap": "Soda", "Fruit en Verse Sappen": "Fruits", "Zuivel en Gekoeld Sap": "Dairy",
         "Gevogelte en Vis Vega": "Meat"}, inplace=True)

    return data




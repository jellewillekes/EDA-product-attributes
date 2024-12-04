# FMCG Product Sales Effect Analysis

This repository showcases the analysis and methodologies developed to evaluate the effects of product attributes on sales for a leading FMCG retailer. The case study centers on Albert Heijn, a market leader in the Dutch retail sector, using advanced panel data techniques to explore how product attributes impact sales across various categories. This project was undertaken as part of the Quantitative Marketing Seminar in the MSc Econometrics and Management Science program, in collaboration with Prakash Bhagat, Richie Lee, and Abdelmounaim el Yaakoubi.

## Problem Statement

Understanding the impact of product attributes (e.g., labels like "Low Sugar," "Vegetarian") on consumer behavior is crucial for optimizing promotional strategies, assortment selection, store design, and more. This study aims to address the following research questions:

- **Main Question**: How do product attributes affect sales across different categories of products?
- **Sub-questions**:
  1. Are individual-specific and group fixed effect models effective in identifying causal relationships between attributes and sales?
  2. How do these effects vary between Albert Heijn’s private-label products and non-AH brands?

## Methodology

### Data Description
The dataset includes:
- **118 products** across 4 categories (`Soda`, `Fruit`, `Meat`, `Dairy`) over 2 years (2018–2019).
- Attributes such as `Biological`, `LowFat`, `Vegetarian`, and others.
- Sales data including relative quantities sold, total sales in Euros, and adjusted prices.

### Models and Approaches
1. **Fixed Effect and Random Effect Models**: To address individual-specific heterogeneity.
2. **Hausman-Taylor Estimator**: Combining strengths of fixed and random effects to account for time-invariant variables.
3. **Grouped Fixed Effects Models**: Utilizing latent class clustering for market segmentation.
4. **Specification Testing Framework**: Implemented tests such as Hausman, Breusch-Pagan, and F-tests to ensure model validity.

### Tools Used
- **Languages**: R (panel data models), Python (data exploration and visualization).
- **Libraries**:
  - Python: `pandas`, `matplotlib`, `seaborn`, `upsetplot`.
  - R: `plm`, `ggplot`.

### Variable Selection
Manual backward selection was applied to optimize model performance, focusing on significant variables for better interpretability.

### Latent Class Analysis
- Identified heterogeneous subgroups within categories using a grouped fixed effect estimator.
- Segmented products based on shared attributes, enabling targeted business strategies.

## Key Findings
1. **Category-specific Patterns**: Significant differences in attribute effects across categories (e.g., "LowFat" is impactful in Soda but not in Meat).
2. **Private vs. Non-Private Labels**: Attributes like `Biological` affect Albert Heijn's private-label products differently than other brands.
3. **Latent Classes**: Identified distinct clusters of products within categories, emphasizing the importance of segmentation in sales strategies.

## Results and Business Implications
- **Dairy Products**: Showed stable sales with significant positive effects from private-label attributes.
- **Soda**: Time effects were more pronounced, with lower sales during certain quarters.
- **Fruit**: Attributes like `Vegetarian` and `Plantbased` strongly influenced sales.
- Recommendations include refining promotional strategies based on the identified attribute effects and emphasizing targeted branding for private-label products.

## Limitations
- Some results are category-specific and may require additional data for validation.
- Endogeneity issues, particularly with price variables, could not be fully addressed due to data constraints.

## Future Work
- Expand the dataset to include more products and longer time spans.
- Address endogeneity concerns using advanced instrumental variable techniques.
- Explore consumer-level data to integrate behavioral insights.

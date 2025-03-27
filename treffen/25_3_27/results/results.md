Resultate der Hyperparameter Analysis 
==============

**Date:** 2025-3-27

**Author:** Flo

**Links**: [MA-Besprechung 2025-03-27](log.md)
 
## Methodik
- Basismodel: 
    - Eindimensionaler Dataset mit Stromverbrauch (Watt)
    - 1 Jahr Training 
    - Hyperparameter: `Number of States`
- Vorhersage:
    - Erwartungswert der Verteilungsvorhersage (=Erwartungswertvorhersage)
    - One-Step-Ahead Sliding-Window Prediction:
        - Ein-Schritt-Prognose: Nur nächste Viertelstunde wird vorhergesagt
        - Sliding-Window: Länge der historischen bekannten Beobachtungen sind fixiert (= `historic window length`)
    - Sensitiviäts-Analyse: Test different `historic window length`
- Evaluation:
    - Eval-Dataset: ersten 2 Wochen jeder Season´
        - Kommentar: Einschränkung auf nur 5 Evaluationen wie vorausgesetzt nicht aussagekräftig => dh kompletten Testdatensatz genommen
    - Variation von `Number of States` und `historic window length`
        - `Number of States` in {5, 10, 20, 30, 40, 50, 60, 80, 100}
        - `historic window length` in {1, 5, 10, 20}
    - MAE der Erwartungswertvorhersage
    - Residual Variance der Erwartungswertvorhersage

<div style="page-break-after: always;"></div>

## Results

- **Graphic Results** for HH 1  (= household number 1)
  ![hyperparameter_analysis_hh(1)_mae](plot_hh(1)_MAE.svg)
  ![hyperparameter_analysis_hh(1)_res_var](plot_hh(1)_ResidualVariance.svg)

<div style="page-break-after: always;"></div>

- **Numeric Results** for HH 1
  - MAE: Lowest score at `Number Of States` = 80 and `Historic Window Length` = 20

|   MAE |       1 |       5 |      10 |      20 |
|------:|--------:|--------:|--------:|--------:|
|    10 | 122.896 | 125.734 | 125.716 | 125.701 |
|    20 | 121.131 | 122.628 | 122.340 | 122.267 |
|    30 | 121.154 | 124.419 | 124.293 | 124.348 |
|    40 | 119.867 | 121.083 | 120.576 | 120.343 |
|    50 | 120.566 | 121.233 | 120.816 | 120.806 |
|    60 | 120.180 | 121.205 | 120.407 | 120.313 |
|    80 | 120.062 | 120.398 | 119.896 | 119.878 |
|   100 | 120.898 | 122.477 | 121.406 | 121.595 |


|   Residual Variance |       1 |       5 |      10 |      20 |
|--------------------:|--------:|--------:|--------:|--------:|
|                  10 | 90108.7 | 92190.0 | 92095.9 | 92079.8 |
|                  20 | 87971.8 | 88566.5 | 88422.9 | 88405.9 |
|                  30 | 88194.4 | 89454.1 | 89427.2 | 89440.3 |
|                  40 | 86877.0 | 85883.7 | 85750.5 | 85565.6 |
|                  50 | 87064.4 | 85493.8 | 85279.9 | 85256.7 |
|                  60 | 87100.4 | 86265.9 | 86176.8 | 86150.5 |
|                  80 | 87181.5 | 85188.8 | 85184.9 | 85354.0 |
|                 100 | 88477.0 | 87609.9 | 87512.3 | 87630.2 |



- **Graphic Results** for HH 2  (= household number 2)
  ![hyperparameter_analysis_hh(2)_mae](plot_hh(2)_MAE.svg)
  ![hyperparameter_analysis_hh(2)_res_var](plot_hh(2)_ResidualVariance.svg)

- **Graphic Results** for HH 3  (= household number 3)
  ![hyperparameter_analysis_hh(3)_mae](plot_hh(3)_MAE.svg)
  ![hyperparameter_analysis_hh(3)_res_var](plot_hh(3)_ResidualVariance.svg)


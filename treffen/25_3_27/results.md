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
    - Erwartungswert der Verteilungsvorhersage
    - One-Step-Ahead Sliding-Window Prediction:
        - Ein-Schritt-Prognose: Nur nächste Viertelstunde wird vorhergesagt
        - Sliding-Window: Länge der historischen bekannten Beobachtungen sind fixiert (= `historic window length`)
    - Sensitiviäts-Analyse: Test different `historic window length`
- Evaluation:
    - Eval-Dataset: ersten 2 Wochen jeder Season´
        - Kommentar: Einschränkung auf nur 5 Evaluationen wie vorausgesetzt nicht aussagekräftig => dh kompletten Testdatensatz genommen
    - Variation von `Number of States` und `historic window length`
        - `Number of States` in {5, 10, 20, 30, 40, 50, 60, 80, 100}
        - `historic window length`in {5, 10, 50, 100}
    - MAE der Erwartungswertvorhersage
    - Residual Variance der Erwartungswertvorhersage

## Results

- Numeric Results for HH 1 (= household number 1)
- Grafic Results for HH 1
- Comparison: Results for HH 2 and HH 3

## Discussion Results and Outlook

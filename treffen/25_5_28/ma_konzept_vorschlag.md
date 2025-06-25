---
output:
  pdf_document: default
  html_document: default
---
# MA Konzept Vorschlag

## Research Questions (RQ)
1. How can HMM be applied as a probabilistic forecasting methode and what is the current state of literature?

2. What are relevant hyperparameters and optimal parameter settings of the HMM model in the use-case of short-term power load forecasting?

3. How can additional information, e.g. seasonality and daytime, be included to benefit the accuracy of the HMM model?

4. How does the HMM model perform compared to other standard power load forecasting methodes?

## Überblick für Ausarbeitung der RQ
1. RQ:
    - Literaturarbeit; 
    - Ausarbeitung Theorie für Vorhersage mit HMM
2. RQ:
    - Überblick Vorgehensweise
        - Basismodel mit 1-dim Lastdaten als Observationen
        - Training auf Daten 1.Jahr; Test/Eval auf Daten 2.Jahr
        - Vorhersage der Verteilung für nächsten Zeitpunkt
        - Evaluieren via standard Scoring Rule (CRPS) 
    - Sensitivitätsanalyse für Identifizierung relevanter Hyperparameter
        - Zu untersuchende Hyperparameter:
            - Diskretiesierungsgrad (möchte 2 Versionen testen: 1. Vorgeschlagene Diskretisierung mit gleich häufigen Klassen und 2. Anwendungsorientierter Diskretisierung, wie etwa äquidistanten Stützstellen)
            - Länge des Vergangenheitsfenster
        - Variabler Parameter:
            - Anzahl der hidden States
        - Fixe Hyperparameter:
            - Trainingsparameter (Init-values, max Iteration von Algo)
            - Vorhersagehorizont = 1 Schritt in die Zukunft (vorerst)
            - Originale Daten (abgesehen von Diskretisierung kein Prepocessing/filtern/Trendanalyse/Clustering)
3. RQ:
    - Erweiterung des Basismodels
    - Seasonal Model: Aufteilung des Basismodells (ganzjahr) in 4 verschiedene Saisonsmodelle
    - Daytime Model: Hinzufügen von Zeitstempeln als 2.Dimension der Observationen

4. RQ: 
    - Benchmarken mit einfachen Standard Modellen.
    - siehe Paper BOTMAN 2025


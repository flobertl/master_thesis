# MA Besprechung 2025-3-27

## Agenda 
1. Allgemeines
2. Feedback K2, K3, K4
3. Diskussion und Fragen
4. Benchmark
5. Outlook und Zeitplan
 

## Diskussion und Fragen 
- Kommentar zu Feedback: 
    - Deterministic prediction vs point forecast
    - CDF valued
    - PIT in figure
    - Zeit t in HMM parameter A/B
    - Notion consistency for I_T nicht implementiert, weil manchmal 1 bis T-1, und manchmal 2 bis T,...
    - Umdrehen von i und j in alpha
- Struktur von MA
    - K2 so lassen oder HMM Forecasting zu einem ganzen Kapitel aufblasen
    - In K3.Methodlogy einführung via Kapitel “Concept”? (Erklärung zur anwendung von HMM, keine Vermischung von Methodik mit konzeptuellen ideen?)
- Formale Sachen
    - Mache manchmal \cdot (vorallem bei a und b) manchmal ned 
    - Mix zwischen Discretisation Type A vs equal-mass bins


## Log
- Állgemein: Chaotisch. Zuerst feedback zu schon reviewetem teil ("Evaluation kann nicht evaluation benannt werden" weil in literatur gibts das nicht, Rabiner Seite 1: Evaluation), dann halbe stunde pause um Methodik und Results zu reviewen.
- Feedback:
    - K2:
        - neue Algorithms noch nicht reviewed
        - Forecasting
            - matrix formulierung anders herleiten. Via Markov 
                - siehe notizen ![alt text](<HMM Forecasting herleitung.jpeg>)
            - Aufwandoptimierung woandershin, aber nicht gesagt wohin
            - Er mag UNBEDINGT alle forecasting methoden ausgeschrieben
                - hat wenig Prio für mich
            - Und eigenes Kapitel
                - Zuerst: ja die Struktur passt so
                - dann: na ein eigenes kapitel is scho wichtig
    - K3
        - Strukturell
            - Daten als erstes Kapitel
            - Hyperparameter "Tuning" in die Methodology
            - Experiments:
                - auch Model Analysis hingeben
            - Evaluation als eigene Section
        - Einleitung iwas machen, kA
        - Forecasting und Preprocessing (keine Evaluation)
    - K4
        - Keine Apendix, alles rein - wieso auch immer.
- Wichtige 3 Punkte:
    - Heutige Änderungen
    - Benchmark (nur ein Baseline, Erweiterungen in zukünftigem Paper)
    - Keyfactor/eine interpretierbare Zahl.
        - CRPS interpretieren, bzw. interpretierbare metrik einführen
        - Evtl. mit Pinball zu argumentieren
- Outlook:
    - nächstes Wochenende - Abgabe von Hauptteil, evtl. Conclusion/Intro
    - Nächstes Meeting am 25.11.  Nachmittag für 2h
        - Noch eine iteration (vor übernächstes Treffen Komplette 1.Version abgeben für aller letztes Feedback)
    - Abgabetermin abschicken. 7.Jänner. 

            

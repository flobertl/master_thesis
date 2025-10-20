# MA Besprechung 2025-09-02

## Agenda 
1. Allgemeines
2. Momentaner Status
3. Konkrete Schritte
4. Zeitlicher Rahmen 
 

## Fragen
- Grafen direkt übernehmen
    - Wie direktzitate
    - Erlaubt, einfach nach Zitierregeln
- Zu Lehrbuch-artiger Stil oder ok für mas  ter arbeit
    - Kann er erst nach Durchlesen beurteilen
- Bei Wahrscheinlichkeitsausdrücken
    - Abstände okay oder nicht? Glaube schon
    - Ist P(X | Y) vs P(X = x | Y=y) klar?
        - saubere Notation in wissenschaftlichen Texten notwendig (nicht wie in Vorlesung ect.)
        - Eigene Notation für schon festgelegte Zufallsvariablen.
- Auswahlkriterion für optimale hyperparameter
    - Modell mit bestem CRPS 
    - jeweils ein Modell pro Diskretisierungstyp

## Log
- Ergebnisse passen
- Vorschlag mehrere Fehlermetriken (loglikelihood, anderes Verteilungsmass, mae, quantil-schätzer)
    - Kommentar für mich im Nachhinein: 
        - loglikelihood nur für diskrete modelle direkt nutzbar.
            - man könnte aber die Dichtewerte hernehmen. Keine ahnung wie vergleichbar dies wäre...
        - schlecht umsetzbar außer quantilschätze
        - mae wäre scho implementiert aber fragwürdig
- Vorgeschlagener Zeitplan:
    - In den nächsten 1-2 Wochen Theorie abschicken
    - bis Mitte Oktober Benchmarks abschließen  
    - Dezember/Jänner abschließen
- Meine Zeitvorstellung:
        - 1. Sept. Woche: 
            - Code: Research Benchmark und Festlegung auf Modelle bzw Datensatz
            - Schreiben: Abschicken Teil 1 Theorie (Prob.Forecasting, Forward Algo)
        - 2+3. Sept Woche:
            - Code: Implementierung Benchmark
            - Schreiben: Einarbeitung Feedback, Algos fertig, evtl beginn mit Forecast Theorie
        - Ab. 4.Sept Woche + Oktober:
            - Code: Ausführung Experiment, Visualisierung der Ergebnisse
            - Schreiben: 
                - Anfang von Experiment Design/Methodik (2 Wochen)
                - Results (2 Wochen)
                - Benchmark (2 Wochen)
            - Im bestenfall schon Kapitel vorher abgeben und in Revision
        - November:
            - 1.Iteration Feedback (1 Woche)
            - Intro, Conclusio, Abstract (1 Woche)
            - 2. Itertation Feedback (1 Woche)
            - Korrekturleses lassen (Trixi/Antonio, Christoph)


# Besprechung MA 2025-1-15

## Inhalt
- Presentation der ersten Experimente
    - [Präsi erste Experimente](log.md)
- Übersicht Fortschritt "Qualitative Analyse"
- Konkrete Ergebnisse aus Experimenten
- Fragen, Diskussion

## Log Experiment Setup (Transcript von Fotos)

1. Aufsplitten Dataset: 60:20:20 Training:Eval:Test
2. Verlauf
    - Training
    - Hyperparameter
    - Test
3. Test
    - nur mit Testset
4. Experimentenreihe
    1. Bestimmen von T und S (T = Länge trainings daten; S = Anzahl states)
        - Variante A: 1 Jahr trainieren für S=50/100/150/200/250/300
        - Variante B: 2 Jahre Training
        - Testen: Erwartungswert One-Step-Ahead Mean Average Error für 5 Stichproben
    2. Abhängigkeit von Länge der Horizontfenster \
        Visuelle Evaluierung:
        - E1: Verteilung
        - E2: Mittelwert
        - E3: Varianz
        1. Experimente Basismodel: WH Experiment 1 + Visuelle Evaluierung
        2. Experiment mit zusätzliche Info (Timestamps): -"-
        3. WH von -"- mit Experimentenreihe 3
    3. Optimale Feature Parameter bestimmen
        1. Wochenclusters finden
        2. Intra-Woche Muster finden
    4. Periodische Datenbereiche zu charakterisieren


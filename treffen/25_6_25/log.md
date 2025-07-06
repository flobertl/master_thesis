# MA Besprechung 2025-6-25
 
## Diskussions Punkte 
- RQs
- Methodik

## Log
- RQ
- Frage 1: Split Trainings/Test
    - Mehrere Optionen durchdiskutiert (60:20:20; 65:20:15; 50:50)
    - Problem der Saisonalität der Daten => nur Daten mit Jahreslänge kommen in Frage => 1 Jahr Trainingsdaten; 2.Jahr Test/Evaluation aufsplitten
    - Frage: Wie 2.Jahr zwischen Test und Evaluation aufsplitten?
        - ersten 15 Tage eines Monats als Testset und zweiten 15 Tage für Evaluierung
- Frage 2: Reihenfolge der Hyperparameter Analyse
    - vorgeschlagene Methodik passt.
- Vorschlag für weitere Evaluierungsmetrik: log-likelihood mit Einbinden; Gut eine 2.Metrik zu haben
- Vorschlag Daten zu deckeln: oberer schranke bei empirischer alpha quantil und alle Werte darüber "abzuschneiden". Verkompliziert Diskretisierung mehr und führt extra hyperparameter ein




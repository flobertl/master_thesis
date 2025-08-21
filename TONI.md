# Taskbeschreibung für TONI

1. Setup
- Schaun ob Git Repo noch lokal abgespeichert ist. Evtl unter "Dokumente/" und Flos Masterarbeit oder sowas.
    - Sonst Repo neu klonen in VS Code: https://github.com/flobertl/master_thesis.git
- VS Code auf neuesten Stand bringen
    - 'Julia' Extension aktualisieren/installieren
    - Notwendige Packete aktualisieren:
        1. Öffne Dokument 'TONIS_setup.jl' in HMM_Forecast/script
        2. Markiere Code und führe aus via 'Strg + ENTER' 
        Dauert wsl ein bissl...
- Ruhemodus am Laptop umstellen
    - Am besten du steckst den Laptop an und sagst Windows dass er niemals in Ruhemodus gehen soll. (Im Ruhemodus werden Berechnungen gestoppt)

2. Task 1: Erste Modelle berechnen
    - Beschreibung: Berechnung von 8 Modellen, mit welchen ich erste Rückschlüsse ziehne möchte ob das endlich ausreicht oder ob noch größere Modelle berechnet werden sollen.
    - Task: 
        1. Dokument 'TONIS_task1.jl' in HMM_Forecast/script
        2. Markiere Code und führe aus via 'Strg + ENTER' 
        3. Wenn erste Trainingsiterationen durchlaufen, schick mir die Dauer von einer Iteration (wird alles geprintet). Dann kann ich abschätzen wie lange es dauern wird. Gehe momentan von ca. einem Tag aus. 
        4. Ergebnisse werden automatisch abgespeichert; Also einfach nur einen neuen Git-Commit machen (zb mit 'Tonis Task 1'), und pushen. 

3. Task 2: 
    - Werde Ergebnisse aus Task 1 analysieren und ggfalls Script für Task 2 adaptieren. Gebe dir dann Bescheid wenn du es ausführen kannst
    - Task 2:
        1. Evtl. git pull
        2. Dokument 'TONIS_task2.jl' in HMM_Forecast/script
        3. Markiere Code und führe aus via 'Strg + ENTER'
        4. Wenn fertig, commite und pushe.  
    





# Zadanie 1 – zbiór Wesbrook

## Treść zadania

Proszę zaimportować, dokonać wstępnej analizy i przygotować do obróbki zbiór Wesbrook znajdujący się pod adresem
http://jolej.linuxpl.info/Wesbrook.csv. W tym celu należy:

1. Zaimportować zbiór danych z odpowiednimi typami zmiennych z użyciem funkcji `read_csv()`.
2. Dokonać wstępnej analizy zbioru z wykorzystaniem statystyk opisowych.
3. Dokonać analizy istotności zmiennych, utworzyć nowy zbiór Wesbrook2 zawierający tylko istotne zmienne.
4. Wykonać wizualną analizę danych; w ramach analizy wizualnej rozkład zmiennych numerycznych przedstawić na jednym
   wykresie macierzowym, używając histogramów.
5. Przygotować dane do analizy. W tym celu:
   - dokonać imputacji brakujących wartości,
   - dokonać normalizacji zmiennych numerycznych metodą z-score i min-max,
   - wykonać kodowanie zero-jedynkowe (wprowadzić zmienne sztuczne) dla zmiennej MARITAL,
   - wykonać próbkowanie warstwowe, dzieląc zbiór na treningowy i walidacyjny w proporcji 80% do 20% według zmiennej WESBROOK.

## Opis zmiennych

Zmienne pogrupowane tematycznie:

- **dane techniczne**
  - `ID` – numer rekordu
  - `INDUPDT` – data aktualizacji rekordu
  - `EA` – kod regionu
- **wpłaty**
  - `TOTLGIVE` – łączna kwota darowizn
  - `WESBROOK` – czy osoba należy do grupy Wesbrook (Y/N) – zmienna objaśniana
- **studia na UBC**
  - `GRADYR1` – rok uzyskania stopnia
  - `FRSTYEAR` – rok pierwszego stopnia
  - `FACULTY1` – wydział
  - `DEPT1` – katedra
  - `MAJOR1` – kierunek
- **osoba**
  - `SEX` – płeć
  - `MARITAL` – stan cywilny
  - `PARENT` – rodzic studenta UBC
  - `CHILD` – dziecko absolwenta
  - `SPOUSE` – małżonek studenta lub absolwenta
  - `FACSTAFF` – pracownik UBC
  - `ATHLTCS` – udział w zajęciach sportowych
  - `OTHERACT` – udział w innych aktywnościach
  - `BIGBLOCK` – udział w programie BIGBLOCK
- **region zamieszkania**
  - `PROV` – prowincja
  - `HH_1PER`, `HH_2PER`, `HH_3PER`, `HH_45PER` – odsetek gospodarstw 1, 2, 3 i 4-5 osobowych
  - `AVE_INC` – średni dochód
  - `SD_INC` – odchylenie standardowe dochodu
  - `DWEL_VAL` – średnia wartość mieszkania
  - `MOV_DWEL` – odsetek gospodarstw w domach mobilnych
  - `CNDN_PCT` – odsetek obywateli Kanady
  - `ENG_PCT` – odsetek osób z angielskim jako pierwszym językiem
  - `OWN_PCT` – odsetek właścicieli mieszkań

## Pliki

- `Wesbrook.ipynb` – notatnik (R) z rozwiązaniem i opisem kolejnych kroków
- `zad1.R` – ten sam kod jako skrypt R

# Zadanie 3 – regresja logistyczna (zbiór Bank Marketing)

## Cel

Zbudować model regresji logistycznej przewidujący, czy klient banku założy lokatę terminową (`y`), dokonać redukcji
zmiennych, sprawdzić model nieliniowy i wybrać najlepszy. Metody jak na zajęciach na zbiorze CCS
(http://jolej.linuxpl.info/CCS.htm).

## Dane

Bank Marketing (kampania telemarketingowa portugalskiego banku, 2008–2010), plik `bank-full.csv` – 45 211 klientów, 17 kolumn.

Źródło: S. Moro, R. Laureano and P. Cortez. Using Data Mining for Bank Direct Marketing: An Application of the CRISP-DM
Methodology. In P. Novais et al. (Eds.), Proceedings of the European Simulation and Modelling Conference - ESM'2011,
pp. 117-121, Guimarães, Portugal, October, 2011. EUROSIS.

## Opis zmiennych

- **klient**
  - `age` – wiek
  - `job` – zawód
  - `marital` – stan cywilny
  - `education` – wykształcenie
  - `default` – czy ma niespłacony kredyt
  - `balance` – średnie roczne saldo (euro)
  - `housing` – czy ma kredyt hipoteczny
  - `loan` – czy ma kredyt gotówkowy
- **obecna kampania**
  - `contact` – rodzaj kontaktu (komórka, telefon stacjonarny, nieznany)
  - `day`, `month` – dzień i miesiąc ostatniego kontaktu
  - `duration` – długość ostatniej rozmowy w sekundach
  - `campaign` – liczba kontaktów z klientem w tej kampanii
- **poprzednie kampanie**
  - `pdays` – liczba dni od ostatniego kontaktu w poprzedniej kampanii (-1 = brak kontaktu)
  - `previous` – liczba kontaktów przed tą kampanią
  - `poutcome` – wynik poprzedniej kampanii
- **zmienna objaśniana**
  - `y` – czy klient założył lokatę terminową (yes/no)

## Pliki

- `Bank.ipynb` – notatnik (R) z rozwiązaniem i opisem kolejnych kroków
- `zad3.R` – ten sam kod jako skrypt R
- `bank-full.csv` – dane

# Zadanie 2 – analiza regresji (zbiór Bike Sharing)

## Cel

Na podstawie zbioru Bike Sharing zbudować model regresji liniowej i nieliniowej dla liczby wypożyczeń rowerów (`cnt`),
dokonać redukcji zmiennych dla obu modeli i wybrać najlepszy.

## Dane

Bike Sharing Dataset (Capital Bikeshare, Waszyngton, 2011–2012), dostępny w UCI Machine Learning Repository.

- `day.csv` – dane dzienne (731 dni)
- `hour.csv` – dane godzinowe (17 379 godzin)

Źródło: Fanaee-T, Hadi, and Gama, Joao, "Event labeling combining ensemble detectors and background knowledge",
Progress in Artificial Intelligence (2013): pp. 1-15, Springer Berlin Heidelberg, doi:10.1007/s13748-013-0040-3.

## Opis zmiennych

- **czas**
  - `instant` – numer rekordu
  - `dteday` – data
  - `season` – pora roku (1 wiosna, 2 lato, 3 jesień, 4 zima)
  - `yr` – rok (0 = 2011, 1 = 2012)
  - `mnth` – miesiąc (1–12)
  - `hr` – godzina (0–23, tylko w `hour.csv`)
  - `holiday` – czy dzień jest świętem
  - `weekday` – dzień tygodnia
  - `workingday` – czy dzień jest roboczy (nie weekend i nie święto)
- **pogoda**
  - `weathersit` – 1 ładnie / lekkie zachmurzenie, 2 mgła i chmury, 3 lekki deszcz lub śnieg, 4 ulewa, śnieżyca
  - `temp` – temperatura (przeskalowana, podzielona przez 41)
  - `atemp` – temperatura odczuwalna (podzielona przez 50)
  - `hum` – wilgotność (podzielona przez 100)
  - `windspeed` – prędkość wiatru (podzielona przez 67)
- **wypożyczenia**
  - `casual` – wypożyczenia użytkowników okazjonalnych
  - `registered` – wypożyczenia użytkowników zarejestrowanych
  - `cnt` – wszystkie wypożyczenia (zmienna objaśniana)

## Pliki

- `zad2.ipynb` – notatnik (R) z rozwiązaniem i opisem kolejnych kroków
- `zad2.R` – ten sam kod jako skrypt R
- `day.csv`, `hour.csv` – dane

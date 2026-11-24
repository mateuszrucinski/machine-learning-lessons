# MUM - zadanie 1 (zbior Wesbrook)
# Kod zgodny z notatnikiem Wesbrook.ipynb

library(tidyverse)
library(sqldf)
library(gridExtra)

wesbrooks <- read_csv('http://jolej.linuxpl.info/Wesbrook.csv',
                      col_types = "ifnDiffffffffcffffinnnnnnnfnnnn",
                      locale = locale(date_format = "%m/%d/%Y"))

wesbrooks <- wesbrooks %>%
  mutate(across(c(PARENT, CHILD, SPOUSE, FACSTAFF, ATHLTCS, OTHERACT), ~ .x == "Y"))

glimpse(wesbrooks)


#------------------------------------------------------------
# Wstępna analiza zmiennych
#------------------------------------------------------------

summary(wesbrooks)

sqldf('SELECT * FROM wesbrooks LIMIT 10')

braki <- colSums(is.na(wesbrooks))
braki[braki > 0]

Wesbrook2 <- wesbrooks %>%
  select(-ID, -EA, -INDUPDT)

sqldf('SELECT BIGBLOCK, COUNT(*) AS liczba FROM wesbrooks GROUP BY BIGBLOCK')

sqldf('SELECT MOV_DWEL FROM wesbrooks WHERE MOV_DWEL > 0 ORDER BY MOV_DWEL DESC')

prop.table(table(wesbrooks$MOV_DWEL == 0))

Wesbrook2 <- Wesbrook2 %>%
  select(-BIGBLOCK, -MOV_DWEL)

#histogram rocznikow ukonczenia studiow
wesbrooks %>%
  ggplot() +
  geom_histogram(
    mapping = aes(x = GRADYR1),
    binwidth = 1,
    fill = "cyan",
    color = "black"
  ) +
  labs(title = "Histogram of Graduation Year", x = "Graduation year (GRADYR1)", y = "Number of people") +
  theme_minimal() +
  theme(text = element_text(size = 14))

#histogram rocznikow ktore wplacaly oraz ktore nie
wesbrooks %>%
  ggplot() +
  geom_bar(mapping = aes(x = GRADYR1, fill = WESBROOK), color = "black") +
  labs(title = "Wesbrook Donors vs. Non-donors by Graduation Year", x = "Graduation year (GRADYR1)", y = "Number of people") +
  theme_minimal() +
  theme(text = element_text(size = 14))

#brak zer ale wielka skala max i drugiego wyniku
sqldf('SELECT TOTLGIVE FROM wesbrooks ORDER BY TOTLGIVE DESC LIMIT 100')

wesbrooks %>%
  filter(TOTLGIVE < 300000) %>%
  ggplot() +
  geom_boxplot(mapping = aes(x = WESBROOK, y = TOTLGIVE), fill = "red") +
  labs(title = "Boxplot of Total Donations by Wesbrook Status", x = "WESBROOK", y = "Total donations (TOTLGIVE)") +
  theme_minimal()

wesbrooks %>%
  ggplot() +
  geom_point(
    mapping = aes(x = GRADYR1, y = TOTLGIVE),
    color = "blue",
    size = 2
  ) +
  labs(title = "Scatterplot of Total Donations vs. Graduation Year",
       x = "Graduation year (GRADYR1)",
       y = "Total donations (TOTLGIVE)") +
  theme_minimal() +
  theme(text = element_text(size = 14))

#wyrzucenie outliera z analizy (tylko na wykresie)
wesbrooks %>%
  filter(TOTLGIVE < 300000) %>%
  ggplot() +
  geom_point(
    mapping = aes(x = GRADYR1, y = TOTLGIVE),
    color = "blue",
    size = 2
  ) +
  labs(title = "Scatterplot of Total Donations vs. Graduation Year (without outlier)",
       x = "Graduation year (GRADYR1)",
       y = "Total donations (TOTLGIVE)") +
  theme_minimal() +
  theme(text = element_text(size = 14))


#------------------------------------------------------------
# Analiza istotności zmiennych
#------------------------------------------------------------

wesbrooks %>%
  mutate(PRZEDZIAL = cut(TOTLGIVE, breaks = c(0, 100, 500, 1000, 5000, Inf), right = FALSE)) %>%
  select(PRZEDZIAL, WESBROOK) %>%
  table() %>%
  prop.table(margin = 1)

# prosta reguła: TOTLGIVE >= 1000 -> Y
table(wesbrooks$TOTLGIVE >= 1000, wesbrooks$WESBROOK)
mean((wesbrooks$TOTLGIVE >= 1000) == (wesbrooks$WESBROOK == "Y"))

prop.table(table(wesbrooks$WESBROOK))

prop.table(table(wesbrooks$SEX,      wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$PARENT,   wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$CHILD,    wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$SPOUSE,   wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$FACSTAFF, wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$ATHLTCS,  wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$OTHERACT, wesbrooks$WESBROOK), margin = 1)

prop.table(table(wesbrooks$MARITAL,  wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$FACULTY1, wesbrooks$WESBROOK), margin = 1)
prop.table(table(wesbrooks$PROV,     wesbrooks$WESBROOK), margin = 1)

wesbrooks %>%
  ggplot() +
  geom_bar(mapping = aes(x = MARITAL, fill = WESBROOK), color = "black", position = "fill") +
  labs(title = "Share of Wesbrook Donors by Marital Status", x = "MARITAL", y = "Share") +
  theme_minimal() +
  theme(text = element_text(size = 14))

wesbrooks %>%
  select(FACULTY1, DEPT1, MAJOR1) %>%
  summarize(across(everything(), list(kategorie = ~ n_distinct(.x, na.rm = TRUE),
                                      braki = ~ sum(is.na(.x)),
                                      procent_brakow = ~ round(mean(is.na(.x)) * 100, 1))))

Wesbrook2 <- Wesbrook2 %>%
  select(-MAJOR1, -DEPT1)

numeryczne <- c("GRADYR1", "AVE_INC", "SD_INC", "DWEL_VAL", "HH_1PER", "HH_2PER",
                "HH_3PER", "HH_45PER", "CNDN_PCT", "ENG_PCT", "OWN_PCT")

options(repr.plot.width = 16, repr.plot.height = 11)

pudelka <- lapply(numeryczne, function(kol) {
  wesbrooks %>%
    ggplot() +
    geom_boxplot(mapping = aes(x = WESBROOK, y = .data[[kol]]), fill = "red") +
    labs(title = kol, x = "WESBROOK", y = kol) +
    theme_minimal()
})
grid.arrange(grobs = pudelka, ncol = 4)

wesbrooks %>%
  group_by(WESBROOK) %>%
  summarize(across(all_of(numeryczne), ~ median(.x, na.rm = TRUE)))

Wesbrook2 <- Wesbrook2 %>%
  select(-HH_1PER, -HH_2PER, -HH_3PER, -HH_45PER, -CNDN_PCT, -ENG_PCT, -OWN_PCT)

wesbrooks %>%
  select(TOTLGIVE, GRADYR1, FRSTYEAR, AVE_INC, SD_INC, DWEL_VAL) %>%
  cor(use = "pairwise.complete.obs") %>%
  round(2)

Wesbrook2 <- Wesbrook2 %>%
  select(-FRSTYEAR, -SD_INC)

glimpse(Wesbrook2)


#------------------------------------------------------------
# Wizualna analiza zmiennych numerycznych
#------------------------------------------------------------

numeryczne2 <- c("TOTLGIVE", "GRADYR1", "AVE_INC", "DWEL_VAL")

options(repr.plot.width = 14, repr.plot.height = 9)

histogramy <- lapply(numeryczne2, function(kol) {
  Wesbrook2 %>%
    ggplot() +
    geom_histogram(mapping = aes(x = .data[[kol]]), bins = 30, fill = "cyan", color = "black") +
    labs(title = kol, x = kol, y = "Liczba osób") +
    theme_minimal() +
    theme(text = element_text(size = 14))
})
grid.arrange(grobs = histogramy, ncol = 2)


#------------------------------------------------------------
# Imputacja brakujących danych
#------------------------------------------------------------

braki2 <- colSums(is.na(Wesbrook2))
braki2[braki2 > 0]

Wesbrook2 <- Wesbrook2 %>%
  mutate(GRADUATED = !is.na(GRADYR1)) %>%
  mutate(GRADYR1 = ifelse(is.na(GRADYR1), median(GRADYR1, na.rm = TRUE), GRADYR1)) %>%
  mutate(FACULTY1 = as.factor(ifelse(is.na(FACULTY1), "NONE", as.character(FACULTY1)))) %>%
  mutate(MARITAL = as.factor(ifelse(is.na(MARITAL), "U", as.character(MARITAL)))) %>%
  mutate(PROV = as.factor(ifelse(is.na(PROV), "BC", as.character(PROV)))) %>%
  mutate(AVE_INC = ifelse(is.na(AVE_INC), median(AVE_INC, na.rm = TRUE), AVE_INC)) %>%
  mutate(DWEL_VAL = ifelse(is.na(DWEL_VAL), median(DWEL_VAL, na.rm = TRUE), DWEL_VAL))

sum(is.na(Wesbrook2))
summary(Wesbrook2)


#------------------------------------------------------------
# Normalizacja danych
#------------------------------------------------------------

Wesbrook_z <- Wesbrook2 %>%
  mutate(across(where(is.numeric), ~ (.x - mean(.x)) / sd(.x)))

Wesbrook_mm <- Wesbrook2 %>%
  mutate(across(where(is.numeric), ~ ((.x - min(.x)) / (max(.x) - min(.x))) * (1 - 0) + 0))

Wesbrook_z %>%
  select(where(is.numeric)) %>%
  summary()

Wesbrook_mm %>%
  select(where(is.numeric)) %>%
  summary()


#------------------------------------------------------------
# Kodowanie zerojedynkowe zmiennej MARITAL
#------------------------------------------------------------

library(dummies)

Wesbrook3 <- data.frame(Wesbrook_z)
Wesbrook3 <- dummy.data.frame(data = Wesbrook3, names = "MARITAL", sep = "_")

head(Wesbrook3)
colSums(select(Wesbrook3, starts_with("MARITAL")))


#------------------------------------------------------------
# Próbkowanie warstwowe
#------------------------------------------------------------

library(caTools)

set.seed(1234)
sample_set <- sample.split(Wesbrook3$WESBROOK, SplitRatio = 0.8)
Wesbrook_train <- subset(Wesbrook3, sample_set == TRUE)
Wesbrook_valid <- subset(Wesbrook3, sample_set == FALSE)

nrow(Wesbrook_train)
nrow(Wesbrook_valid)

Wesbrook_train %>%
  select(WESBROOK) %>%
  table() %>%
  prop.table()

Wesbrook_valid %>%
  select(WESBROOK) %>%
  table() %>%
  prop.table()

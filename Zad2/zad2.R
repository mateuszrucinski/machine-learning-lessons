# MUM - zadanie 2 (analiza regresji, zbior Bike Sharing)
# Kod zgodny z notatnikiem BikeSharing.ipynb
# Uruchamiac z folderu Zad2 (pliki day.csv i hour.csv)

library(tidyverse)
library(car)
library(corrplot)

options(repr.plot.width = 14, repr.plot.height = 8)

day <- read_csv("day.csv", col_types = "iDfffffffnnnniii")
hour <- read_csv("hour.csv", col_types = "iDffffffffnnnniii")

glimpse(day)


#------------------------------------------------------------
# Wstępna analiza zmiennych
#------------------------------------------------------------

summary(day)

sum(is.na(day))
sum(is.na(hour))

day %>%
  filter(hum == 0 | cnt < 100) %>%
  select(dteday, weathersit, hum, cnt)

day <- day %>%
  mutate(hum = ifelse(hum == 0, median(hum), hum))

day %>%
  ggplot() +
  geom_line(mapping = aes(x = dteday, y = cnt), color = "red") +
  labs(title = "Bike Rentals per Day", x = "Date", y = "Rentals (cnt)") +
  theme_minimal() +
  theme(text = element_text(size = 14))


#------------------------------------------------------------
# Korelacje
#------------------------------------------------------------

# czy cnt to suma casual i registered
all(day$cnt == day$casual + day$registered)

kor <- cor(select(day, temp, atemp, hum, windspeed, casual, registered, cnt))
corrplot(kor, method = "number")

scatterplotMatrix(~ cnt + temp + hum + windspeed, data = day, diagonal = list(method = "boxplot"))

scatterplot(cnt ~ temp, data = day, boxplots = "xy")

par(mfrow = c(2, 2))
Boxplot(cnt ~ season, data = day, main = "season")
Boxplot(cnt ~ weathersit, data = day, main = "weathersit")
Boxplot(cnt ~ weekday, data = day, main = "weekday")
Boxplot(cnt ~ holiday, data = day, main = "holiday")

table(day$workingday, day$weekday)


#------------------------------------------------------------
# Model liniowy (day)
#------------------------------------------------------------

day.model1 <- lm(cnt ~ season + yr + mnth + holiday + weekday + weathersit + temp + hum + windspeed, data = day)
summary(day.model1)

Anova(day.model1)

modele <- list(
  "pełny"         = day.model1,
  "bez mnth"      = update(day.model1, . ~ . - mnth),
  "bez season"    = update(day.model1, . ~ . - season),
  "bez weekday"   = update(day.model1, . ~ . - weekday),
  "bez holiday"   = update(day.model1, . ~ . - holiday),
  "bez hum"       = update(day.model1, . ~ . - hum),
  "bez windspeed" = update(day.model1, . ~ . - windspeed)
)
sapply(modele, function(m) round(summary(m)$adj.r.squared, 4))


#------------------------------------------------------------
# Model nieliniowy (day)
#------------------------------------------------------------

day.model2 <- lm(cnt ~ season + yr + mnth + holiday + weekday + weathersit + temp + I(temp^2) + hum + windspeed, data = day)
summary(day.model2)

Anova(day.model2)

day$log.cnt <- log(day$cnt)
day$log.temp <- log(day$temp)
day$log.hum <- log(day$hum)
day$log.windspeed <- log(day$windspeed)

day.model3 <- lm(log.cnt ~ season + yr + mnth + holiday + weekday + weathersit + log.temp + log.hum + log.windspeed, data = day)
summary(day.model3)

Anova(day.model3)

day.model4 <- update(day.model3, . ~ . - weekday)

round(c(z_weekday = summary(day.model3)$adj.r.squared, bez_weekday = summary(day.model4)$adj.r.squared), 4)

ocena <- function(model, y, log = FALSE) {
  pred <- if (log) exp(fitted(model)) else fitted(model)
  c(R2 = round(1 - sum((y - pred)^2) / sum((y - mean(y))^2), 3),
    RMSE = round(sqrt(mean((y - pred)^2))))
}

rbind("liniowy"          = ocena(day.model1, day$cnt),
      "liniowy + temp^2" = ocena(day.model2, day$cnt),
      "logarytmiczny"    = ocena(day.model3, day$cnt, log = TRUE))


#------------------------------------------------------------
# Dane godzinowe (hour)
#------------------------------------------------------------

hour %>%
  ggplot() +
  geom_boxplot(mapping = aes(x = hr, y = cnt, fill = workingday)) +
  labs(title = "Bike Rentals by Hour", x = "Hour (hr)", y = "Rentals (cnt)") +
  theme_minimal() +
  theme(text = element_text(size = 14))

hour$log.cnt <- log(hour$cnt)

hour.model1 <- lm(cnt ~ season + yr + mnth + hr + holiday + weekday + weathersit + temp + hum + windspeed, data = hour)
hour.model2 <- lm(log.cnt ~ season + yr + mnth + hr + holiday + weekday + weathersit + temp + hum + windspeed, data = hour)
hour.model3 <- lm(log.cnt ~ season + yr + mnth + hr * workingday + holiday + weathersit + temp + hum + windspeed, data = hour)

Anova(hour.model3)

rbind("liniowy"                       = ocena(hour.model1, hour$cnt),
      "logarytmiczny"                 = ocena(hour.model2, hour$cnt, log = TRUE),
      "logarytmiczny + hr*workingday" = ocena(hour.model3, hour$cnt, log = TRUE))


#------------------------------------------------------------
# Wybór najlepszego modelu
#------------------------------------------------------------

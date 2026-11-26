library(tidyverse)
library(car)
library(caret)
library(caTools)
library(gridExtra)

options(repr.plot.width = 14, repr.plot.height = 8)


#1. wczytanie danych

bank <- read_delim("bank-full.csv", delim = ";", col_types = "iffffifffifiiiiff")

glimpse(bank)



#2. wstępna analiza zmiennych

summary(bank)

prop.table(table(bank$y))

# y jako liczba 0/1 - średnia z niej to odsetek klientów, którzy założyli lokatę
bank$y.num <- ifelse(bank$y == "yes", 1, 0)

bank %>%
  mutate(przedzial = ntile(duration, 5)) %>%
  group_by(przedzial) %>%
  summarize(od = min(duration), do = max(duration), odsetek_yes = round(mean(y.num), 3))

kategoryczne <- c("job", "marital", "education", "default", "housing", "loan", "contact", "month", "poutcome")

wykresy <- lapply(kategoryczne, function(kol) {
  bank %>%
    group_by(.data[[kol]]) %>%
    summarize(odsetek_yes = mean(y.num)) %>%
    ggplot(aes(x = .data[[kol]], y = odsetek_yes, group = 1)) +
    geom_point(size = 3, color = "steelblue") +
    geom_line(color = "steelblue") +
    labs(title = kol, x = kol, y = "Share of yes") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
})
grid.arrange(grobs = wykresy, ncol = 3)

przedzialy <- list(
  age      = bank %>% mutate(przedzial = ntile(age, 5)),
  balance  = bank %>% mutate(przedzial = ntile(balance, 5)),
  campaign = bank %>% mutate(przedzial = cut(campaign, c(0, 1, 2, 3, 5, 10, Inf))),
  previous = bank %>% mutate(przedzial = cut(previous, c(-1, 0, 1, 3, Inf)))
)

wykresy <- lapply(names(przedzialy), function(kol) {
  przedzialy[[kol]] %>%
    group_by(przedzial) %>%
    summarize(odsetek_yes = mean(y.num)) %>%
    ggplot(aes(x = factor(przedzial), y = odsetek_yes, group = 1)) +
    geom_point(size = 3) +
    geom_line() +
    labs(title = kol, x = paste("Bins of", kol), y = "Share of yes") +
    theme_minimal()
})
grid.arrange(grobs = wykresy, ncol = 2)



#3. podział na zbiór treningowy i testowy

set.seed(1234)
sample_set <- sample.split(bank$y, SplitRatio = 0.8)
bank_train <- subset(bank, sample_set == TRUE)
bank_test <- subset(bank, sample_set == FALSE)

prop.table(table(bank_train$y))
prop.table(table(bank_test$y))



#4. model logistyczny - model max

GLM.MAX <- glm(y ~ age + job + marital + education + default + balance + housing + loan + contact + day + month +
                 campaign + pdays + previous + poutcome,
               family = binomial(logit), data = bank_train)
summary(GLM.MAX)

1 - (GLM.MAX$deviance / GLM.MAX$null.deviance) # McFadden R2

Anova(GLM.MAX)

GLM.DUR <- update(GLM.MAX, . ~ . + duration)
1 - (GLM.DUR$deviance / GLM.DUR$null.deviance) # McFadden R2 z duration



#5. redukcja zmiennych - step

GLM.STEP <- step(GLM.MAX, direction = "both", trace = 0)
formula(GLM.STEP)

1 - (GLM.STEP$deviance / GLM.STEP$null.deviance) # McFadden R2



#6. model nieliniowy

bank %>%
  summarise(across(c(age, campaign, previous), ~ sum(.x == 0), .names = "zera_{.col}"))

bank_train <- bank_train %>% mutate(log.campaign = log(campaign), log.previous = log(previous + 1))
bank_test <- bank_test %>% mutate(log.campaign = log(campaign), log.previous = log(previous + 1))

GLM.NONLIN <- glm(y ~ age + I(age^2) + job + marital + education + default + balance + housing + loan + contact + day +
                    month + log.campaign + log.previous + pdays + poutcome,
                  family = binomial(logit), data = bank_train)

1 - (GLM.NONLIN$deviance / GLM.NONLIN$null.deviance) # McFadden R2

Anova(GLM.NONLIN)

GLM.MIX <- glm(y ~ age + I(age^2) + job + marital + education + balance + housing + loan + contact + month +
                 log.campaign + log.previous + poutcome,
               family = binomial(logit), data = bank_train)
summary(GLM.MIX)

1 - (GLM.MIX$deviance / GLM.MIX$null.deviance) # McFadden R2

Anova(GLM.MIX)



#7. ocena modeli na zbiorze testowym

ocena <- function(model) {
  prob <- predict(model, bank_test, type = "response")
  pred <- factor(ifelse(prob > 0.5, "yes", "no"), levels = levels(bank_test$y))
  cm <- confusionMatrix(pred, bank_test$y, positive = "yes")
  top10 <- bank_test$y[order(prob, decreasing = TRUE)][1:round(0.1 * nrow(bank_test))]
  c(McFadden_R2 = round(1 - model$deviance / model$null.deviance, 3),
    AIC = round(AIC(model)),
    trafnosc = round(unname(cm$overall["Accuracy"]), 3),
    czulosc = round(unname(cm$byClass["Sensitivity"]), 3),
    yes_w_top10 = round(mean(top10 == "yes"), 3))
}

rbind("max" = ocena(GLM.MAX), "step" = ocena(GLM.STEP), "nieliniowy zredukowany" = ocena(GLM.MIX))

bank_test$prob <- predict(GLM.MIX, bank_test, type = "response")

for (prog in c(0.5, 0.2)) {
  pred <- factor(ifelse(bank_test$prob > prog, "yes", "no"), levels = levels(bank_test$y))
  cm <- confusionMatrix(pred, bank_test$y, positive = "yes")
  print(paste("próg", prog))
  print(cm$table)
  print(round(c(cm$overall["Accuracy"], cm$byClass[c("Sensitivity", "Precision")]), 3))
}

# klienci, którzy odmówili, a według modelu mieli największą szansę na lokatę
bank_test %>%
  filter(y == "no") %>%
  arrange(desc(prob)) %>%
  select(age, job, balance, contact, month, poutcome, prob) %>%
  head(5)

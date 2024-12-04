install = function() {
  install.packages("readr")
  install.packages("fastDummies")
  install.packages("plm")
  install.packages('Rcpp')
  install.packages("MASS")
  install.packages("remotes")
  install.packages("dplyr")
  install.packages("ggplot2")
  
  library(remotes)
  library(dplyr)
  library(MASS)
  library(Rcpp)
  library(readr)
  library(fastDummies)
  library(plm)
  library(ggplot2)
}

install()

#Load the csv-file from your Files by inserting the path

#SODA --------------------------------------------------------------------------------
set.seed(1)
products_adjusted = read_csv("Desktop/BAQM/SEMINAR/products_adjusted.csv")
dataset_product_attribute_AH_monthly = products_adjusted
dataset_product_attribute_AH_monthly = dataset_product_attribute_AH_monthly[-1]

data = dataset_product_attribute_AH_monthly[, -(3:6)]
data = na.omit(data)

index = data$ItemDescr
brand = data$Brand

data = data[,-(1:2)]

AH = which(brand == "AH")
brand[AH] = 1
brand[-AH] = 0

data = cbind(data, dummy_cols(data$Category)[, -1])
data = data[, -1]

data[, 16:19] = as.numeric(unlist(data[, 16:19]))
data[, 16:19] = log(data[, 16:19])
times = as.numeric(data[, 15])
quarter = ceiling(times%%100/3)

data = cbind(dummy_cols(quarter), data)[,-1]
data = cbind(brand,data)
data[6:19] = as.integer(as.logical(unlist(data[6:19])))
data = data[,-(19:21)]
data$PlantBased.Vegan = ifelse(data$PlantBased == 1 & data$Vegan == 1, 1, 0)



colnames(data)[1] = "AHbrand"
colnames(data)[2] = "quarter1"
colnames(data)[3] = "quarter2"
colnames(data)[4] = "quarter3"
colnames(data)[5] = "quarter4"

#Choose one category for further analysis
sample = which(data$.data_Soda==1)
data = data[sample,-c(22:25)]

index = sort(index[sample])
brand = brand[sample]
quarter = quarter[sample]
times = times[sample]
number.var = 8
group.number = 1
#regressie resultaten
regression = lm(data$SalesGoodsEUR ~ +data$Biological + data$PrivateLabel + data$LowFat
                + data$LowSugar  + data$Vegan +  data$Vegetarian  + data$Sustainable +
                  data$PriceAdjusted + factor(quarter) - 1, data = data)

betas = regression$coefficients
avg = as.vector(betas[(number.var+1):(number.var+group.number*4)])
sdev = as.vector(sqrt(diag(vcov(regression)))[(number.var+1):(number.var+group.number*4)])


# Plot the grouped intercepts over time for each latent class

condition = c(rep("Soda class" , 4))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:4
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)

print(
  ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
    geom_bar(position=position_dodge(), stat="identity", colour='black') +
    geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
    ggtitle("Plot: Soda Latent Classes") +
    xlab("quarter") + ylab("grouped baseline intercept")+
    theme_bw())

#moonthly

m.regression = lm(data$SalesGoodsEUR ~ data$Biological + data$PrivateLabel + data$LowFat
                  + data$LowSugar  + data$Vegan +  data$Vegetarian  + data$Sustainable +
                    data$PriceAdjusted + factor(times) - 1, data = data)

print(summary(m.regression))
print(BIC(m.regression))
betas = m.regression$coefficients 

avg = as.vector(betas[(number.var+1):(number.var+group.number*24)])
sdev = as.vector(sqrt(diag(vcov(m.regression)))[(number.var+1):(number.var+group.number*24)])

# Plot the grouped intercepts over time for each latent class


condition = c(rep("Soda class 1" , 24))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:24
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)

print(
  ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
    geom_bar(position=position_dodge(), stat="identity", colour='black') +
    geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
    ggtitle("Plot: Soda Latent Class") +
    xlab("month") + ylab("grouped baseline intercept")+
    theme_bw())

print(colMeans(data[, -c(1,2)]))

print(unique(index))



#FRUIT ------------------------------------------------------------------------------------------------------

set.seed(1)
products_adjusted = read_csv("Desktop/BAQM/SEMINAR/products_adjusted.csv")
dataset_product_attribute_AH_monthly = products_adjusted
dataset_product_attribute_AH_monthly = dataset_product_attribute_AH_monthly[-1]

data = dataset_product_attribute_AH_monthly[, -(3:6)]
data = na.omit(data)

index = data$ItemDescr
brand = data$Brand

data = data[,-(1:2)]

AH = which(brand == "AH")
brand[AH] = 1
brand[-AH] = 0

data = cbind(data, dummy_cols(data$Category)[, -1])
data = data[, -1]

data[, 16:19] = as.numeric(unlist(data[, 16:19]))
data[, 16:19] = log(data[, 16:19])
times = as.numeric(data[, 15])
quarter = ceiling(times%%100/3)

data = cbind(dummy_cols(quarter), data)[,-1]
data = cbind(brand,data)
data[6:19] = as.integer(as.logical(unlist(data[6:19])))
data = data[,-(19:21)]
data$PlantBased.Vegan = ifelse(data$PlantBased == 1 & data$Vegan == 1, 1, 0)


colnames(data)[1] = "AHbrand"
colnames(data)[2] = "quarter1"
colnames(data)[3] = "quarter2"
colnames(data)[4] = "quarter3"
colnames(data)[5] = "quarter4"

#Choose one category for further analysis
sample = which(data$.data_Fruits==1)
data = data[sample,-c(22:25)]

index = sort(index[sample])
brand = brand[sample]
quarter = quarter[sample]
times = times[sample]

#initializing algorithm

group.number = 4
data = data[order(index), ]
sample = sample(group.number,length(table(index)) , replace = TRUE)
print(sample)
grouplabel = rep(sample,table(index))
grouplabel
data = cbind(grouplabel,data)
colnames(data)[1] = "grouplabel"

old.grouplabel = data$grouplabel
new.grouplabel = numeric(nrow(data))
old.size = 10 + group.number*4
new.size = old.size
old.beta = numeric(old.size)
new.beta = numeric(old.size) +1
iter = 0

while( !all(old.beta == new.beta) & old.size == new.size & iter < 10){
  
  iter = iter + 1
  print(iter)
  
  old.grouplabel = data$grouplabel
  old.beta = new.beta
  old.size = new.size
  print(old.beta)
  
  regression = lm(data$SalesGoodsEUR ~  data$Biological + data$PrivateLabel + data$LowFat + data$LowSalt 
                  + data$LowSugar + data$PlantBased+ data$Vegetarian + data$LocalProduct +
                    data$HighFiber + data$PriceAdjusted + factor(quarter)*factor(data$grouplabel)
                  - factor(data$grouplabel) - factor(quarter) - 1, data = data)
  
  print(summary(regression))
  print(BIC(regression))
  betas = regression$coefficients
  new.beta = betas
  new.size = length(betas) 
  
  residuals = matrix(NA, nrow(data), group.number*4)
  
  
  for(i in 1:nrow(data)){
    for(j in 1:(group.number*4)){
      
      residuals[i,j] = (as.numeric(data$SalesGoodsEUR[i]) - as.numeric(betas[j+(length(betas)-group.number*4)]) - as.numeric(betas[1:(length(betas)-group.number*4)])%*%as.numeric(data[i,-c(1:6, 13, 17, 18, 19, 20, 21, 23)]) ) ^2      
    }
  }
  
  residual.matrix = rowSums(residuals[,1:4])
  for(i in 2:group.number){
    residual.matrix = cbind(residual.matrix, rowSums(residuals[,(4*i-3):(4*i)], na.rm = TRUE))
  }
  
  residual.matrix = as.data.frame(residual.matrix)
  agg = aggregate(residual.matrix,
                  by = list(index),
                  FUN = mean)
  agg = agg[,-1]
  
  print(apply( agg, 1, which.min))
  
  
  new.grouplabel = rep(apply( agg, 1, which.min), table(index))
  
  data$grouplabel = new.grouplabel
  
  for(i in 1:group.number){
    print(colMeans(data[which(data$grouplabel == i), -c(1,2)]))
    
    print(unique(index[which(data$grouplabel == i)]))
    
  }
  
}


avg = as.vector(betas[(length(betas)-group.number*4+1):length(betas)])
sdev = as.vector(sqrt(diag(vcov(regression)))[(length(betas)-group.number*4+1):length(betas)])

# Plot the grouped intercepts over time for each latent class

condition = c(rep("latent class 1" , 4) , rep("latent class 2" , 4),rep("latent class 3" , 4), rep("latent class 4" , 4))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:4
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)


print(ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
        geom_bar(position=position_dodge(), stat="identity", colour='black') +
        geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
        ggtitle("Plot: Fruit Latent Classes") +
        xlab("quarter") + ylab("grouped baseline intercept")+
        theme_bw())


m.regression = lm(data$SalesGoodsEUR ~  data$Biological + data$PrivateLabel + data$LowFat + data$LowSalt 
                + data$LowSugar + data$PlantBased+ data$Vegetarian + data$LocalProduct +
                  data$HighFiber + data$PriceAdjusted + factor(times)*factor(data$grouplabel)
                - factor(data$grouplabel) - factor(times) - 1, data = data)

print(summary(m.regression))
print(BIC(m.regression))
betas = m.regression$coefficients 

avg = as.vector(betas[(length(betas)-group.number*24+1):length(betas)])
sdev = as.vector(sqrt(diag(vcov(m.regression)))[(length(betas)-group.number*24+1):length(betas)])

# Plot the grouped intercepts over time for each latent class


condition = c(rep("latent class 1" , 24) , rep("latent class 2" , 24),rep("latent class 3" , 24), rep("latent class 4" , 24))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:24
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)


print(ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
        geom_bar(position=position_dodge(), stat="identity", colour='black') +
        geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
        ggtitle("Plot: Fruit Latent Classes") +
        xlab("month") + ylab("grouped baseline intercept")+
        theme_bw())





#MEAT -------------------------------------------------------------------------------------

set.seed(1)
products_adjusted = read_csv("Desktop/BAQM/SEMINAR/products_adjusted.csv")
dataset_product_attribute_AH_monthly = products_adjusted
dataset_product_attribute_AH_monthly = dataset_product_attribute_AH_monthly[-1]

data = dataset_product_attribute_AH_monthly[, -(3:6)]
data = na.omit(data)

index = data$ItemDescr
brand = data$Brand

data = data[,-(1:2)]

AH = which(brand == "AH")
brand[AH] = 1
brand[-AH] = 0

data = cbind(data, dummy_cols(data$Category)[, -1])
data = data[, -1]

data[, 16:19] = as.numeric(unlist(data[, 16:19]))
data[, 16:19] = log(data[, 16:19])
times = as.numeric(data[, 15])
quarter = ceiling(times%%100/3)

data = cbind(dummy_cols(quarter), data)[,-1]
data = cbind(brand,data)
data[6:19] = as.integer(as.logical(unlist(data[6:19])))
data = data[,-(19:21)]
data$PlantBased.Vegan = ifelse(data$PlantBased == 1 & data$Vegan == 1, 1, 0)



colnames(data)[1] = "AHbrand"
colnames(data)[2] = "quarter1"
colnames(data)[3] = "quarter2"
colnames(data)[4] = "quarter3"
colnames(data)[5] = "quarter4"

#Choose one category for further analysis
sample = which(data$.data_Meat==1)
data = data[sample,-c(22:25)]

index = sort(index[sample])
brand = brand[sample]
quarter = quarter[sample]
times = times[sample]


#initializing algorithm

group.number = 5
data = data[order(index), ]
sample = sample(group.number,length(table(index)) , replace = TRUE)
print(sample)
grouplabel = rep(sample,table(index))
data = cbind(grouplabel,data)
colnames(data)[1] = "grouplabel"


old.grouplabel = data$grouplabel
new.grouplabel = numeric(nrow(data))
old.size = 13 + group.number*4
new.size = old.size
old.beta = numeric(old.size)
new.beta = numeric(old.size) +1
avg = numeric(old.size)
sdev = numeric(old.size)
iter = 0


while( !all(old.beta == new.beta) & old.size == new.size & iter < 10){
  
  iter = iter + 1
  print(iter)
  
  old.grouplabel = data$grouplabel
  old.beta = new.beta
  old.size = new.size
  print(old.beta)
  
  regression = lm(data$SalesGoodsEUR ~  data$Biological + data$PrivateLabel + data$LowFat + data$LowSalt
                  + data$LowSugar + data$PlantBased + data$Vegan + data$Vegetarian + data$LocalProduct +
                    data$WholeGrain + data$Glutenfree + data$Sustainable + data$PriceAdjusted + factor(quarter)*factor(data$grouplabel)
                  - factor(data$grouplabel) - factor(quarter) - 1, data = data)
  
  print(summary(regression))
  print(BIC(regression))
  betas = regression$coefficients
  new.beta = betas
  new.size = length(betas) 
  
  
  residuals = matrix(NA, nrow(data), group.number*4)
  
  length( as.numeric(betas[1:(length(betas)-group.number*4)]))
  length(as.numeric(data[i,-c(1:6, 16, 20, 21, 23)]))
  
  for(i in 1:nrow(data)){
    for(j in 1:(group.number*4)){
      
      residuals[i,j] = (as.numeric(data$SalesGoodsEUR[i]) - as.numeric(betas[j+(length(betas)-group.number*4)]) - as.numeric(betas[1:(length(betas)-group.number*4)])%*%as.numeric(data[i,-c(1:6, 16, 20, 21, 23)]) ) ^2      
    }
  }
  
  residual.matrix = rowSums(residuals[,1:4])
  for(i in 2:group.number){
    residual.matrix = cbind(residual.matrix, rowSums(residuals[,(4*i-3):(4*i)], na.rm = TRUE))
  }
  
  residual.matrix = as.data.frame(residual.matrix)
  agg = aggregate(residual.matrix,
                  by = list(index),
                  FUN = mean)
  agg = agg[,-1]
  
  print(apply( agg, 1, which.min))
  
  new.grouplabel = rep(apply( agg, 1, which.min), table(index))
  
  data$grouplabel = new.grouplabel
  
  for(i in 1:group.number){
    print(colMeans(data[which(data$grouplabel == i), -c(1,2)]))
    
    print(unique(index[which(data$grouplabel == i)]))
    
  }
  
 
}


avg = as.vector(betas[(length(betas)-group.number*4+1):length(betas)])
sdev = as.vector(sqrt(diag(vcov(regression)))[(length(betas)-group.number*4+1):length(betas)])

#Plot the grouped intercepts over time for each latent class

condition = c(rep("latent class 1" , 4) , rep("latent class 2" , 4), rep("latent class 3" , 4) , rep("latent class 4" , 4) , rep("latent class 5" , 4))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:4
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)


print(ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
        geom_bar(position=position_dodge(), stat="identity", colour='black') +
        geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
        ggtitle("Plot: Meat Latent Classes") +
        xlab("quarter") + ylab("grouped baseline intercept") +
        theme_bw())



#plot monthly


m.regression = lm(data$SalesGoodsEUR ~  data$Biological + data$PrivateLabel + data$LowFat + data$LowSalt
                  + data$LowSugar + data$PlantBased + data$Vegan + data$Vegetarian + data$LocalProduct +
                    data$WholeGrain + data$Glutenfree + data$Sustainable + data$PriceAdjusted + factor(times)*factor(data$grouplabel)
                  - factor(data$grouplabel) - factor(times) - 1, data = data)

print(summary(m.regression))
print(BIC(m.regression))
betas = m.regression$coefficients 

avg = as.vector(betas[(length(betas)-group.number*24+1):length(betas)])
sdev = as.vector(sqrt(diag(vcov(m.regression)))[(length(betas)-group.number*24+1):length(betas)])

# Plot the grouped intercepts over time for each latent class


condition = c(rep("latent class 1" , 24) , rep("latent class 2" , 24),rep("latent class 3" , 24), rep("latent class 4" , 24),rep("latent class 5" , 24))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:24
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)


print(ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
        geom_bar(position=position_dodge(), stat="identity", colour='black') +
        geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
        ggtitle("Plot: Meat Latent Classes") +
        xlab("month") + ylab("grouped baseline intercept")+
        theme_bw())



#DAIRY -----------------------------------------------------------------------------------
products_adjusted = read_csv("Desktop/BAQM/SEMINAR/products_adjusted.csv")
dataset_product_attribute_AH_monthly = products_adjusted
dataset_product_attribute_AH_monthly = dataset_product_attribute_AH_monthly[-1]

data = dataset_product_attribute_AH_monthly[, -(3:6)]
data = na.omit(data)

index = data$ItemDescr
brand = data$Brand

data = data[,-(1:2)]

AH = which(brand == "AH")
brand[AH] = 1
brand[-AH] = 0

data = cbind(data, dummy_cols(data$Category)[, -1])
data = data[, -1]

data[, 16:19] = as.numeric(unlist(data[, 16:19]))
data[, 16:19] = log(data[, 16:19])
times = as.numeric(data[, 15])
quarter = ceiling(times%%100/3)

data = cbind(dummy_cols(quarter), data)[,-1]
data = cbind(brand,data)
data[6:19] = as.integer(as.logical(unlist(data[6:19])))
data = data[,-(19:21)]
data$PlantBased.Vegan = ifelse(data$PlantBased == 1 & data$Vegan == 1, 1, 0)



colnames(data)[1] = "AHbrand"
colnames(data)[2] = "quarter1"
colnames(data)[3] = "quarter2"
colnames(data)[4] = "quarter3"
colnames(data)[5] = "quarter4"

#Choose one category for further analysis

sample = which(data$.data_Dairy==1)
data = data[sample,-c(22:25)]

index = sort(index[sample])
brand = brand[sample]
quarter = quarter[sample]
times = times[sample]


#initializing algorithm

group.number = 4
data = data[order(index), ]
sample = sample(group.number,length(table(index)) , replace = TRUE)
print(sample)
grouplabel = rep(sample,table(index))
data = cbind(grouplabel,data)
colnames(data)[1] = "grouplabel"

old.grouplabel = data$grouplabel
new.grouplabel = numeric(nrow(data))
old.size = 12 + group.number*4
new.size = old.size
old.beta = numeric(old.size)
new.beta = numeric(old.size) +1
avg = numeric(old.size)
sdev = numeric(old.size)

iter = 0

while( !all(old.beta == new.beta) & old.size == new.size & iter < 10){
  
  iter = iter + 1
  print(iter)
  
  old.grouplabel = data$grouplabel
  old.beta = new.beta
  old.size = new.size
  print(old.beta)
  
  regression = lm(data$SalesGoodsEUR ~  data$Biological + data$PrivateLabel + data$LowFat + data$LowSalt
                  + data$LowSugar + data$PlantBased+ data$Vegetarian + data$LocalProduct +
                    data$WholeGrain +data$Glutenfree + data$Sustainable + data$PriceAdjusted + factor(quarter)*factor(data$grouplabel)
                  - factor(data$grouplabel) - factor(quarter) - 1, data = data)
  
  print(summary(regression))
  print(BIC(regression))
  betas = regression$coefficients
  new.beta = betas
  new.size = length(betas) 
  
  residuals = matrix(NA, nrow(data), group.number*4)
  
  
  for(i in 1:nrow(data)){
    for(j in 1:(group.number*4)){
      
      residuals[i,j] = (as.numeric(data$SalesGoodsEUR[i]) - as.numeric(betas[j+(length(betas)-group.number*4)]) - as.numeric(betas[1:(length(betas)-group.number*4)])%*%as.numeric(data[i,-c(1:6, 13, 16, 20, 21, 23)]) ) ^2      
    }
  }
  
  residual.matrix = rowSums(residuals[,1:4])
  for(i in 2:group.number){
    residual.matrix = cbind(residual.matrix, rowSums(residuals[,(4*i-3):(4*i)], na.rm = TRUE))
  }
  
  
  residual.matrix = as.data.frame(residual.matrix)
  agg = aggregate(residual.matrix,
                  by = list(index),
                  FUN = mean)
  agg = agg[,-1]
  
  print(apply( agg, 1, which.min))
  
  new.grouplabel = rep(apply( agg, 1, which.min), table(index))
  
  data$grouplabel = new.grouplabel
  

  
  
}


for(i in 1:group.number){
  print(colMeans(data[which(data$grouplabel == i), -c(1,2)]))
  
  print(unique(index[which(data$grouplabel == i)]))
  
}

avg = as.vector(betas[(length(betas)-group.number*4+1):length(betas)])
sdev = as.vector(sqrt(diag(vcov(regression)))[(length(betas)-group.number*4+1):length(betas)])


condition = c(rep("latent class 1" , 4) , rep("latent class 2" , 4),rep("latent class 3" , 4), rep("latent class 4" , 4))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:4
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)


print(ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
        geom_bar(position=position_dodge(), stat="identity", colour='black') +
        geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
        ggtitle("Plot: Diary Latent Classes") +
        xlab("quarter") + ylab("grouped baseline intercept")+
        theme_bw())

#plot monthly


m.regression = lm(data$SalesGoodsEUR ~  data$Biological + data$PrivateLabel + data$LowFat + data$LowSalt
                  + data$LowSugar + data$PlantBased+ data$Vegetarian + data$LocalProduct +
                    data$WholeGrain +data$Glutenfree + data$Sustainable + data$PriceAdjusted + factor(times)*factor(data$grouplabel)
                  - factor(data$grouplabel) - factor(times) - 1, data = data)

print(summary(m.regression))
print(BIC(m.regression))
betas = m.regression$coefficients 

avg = as.vector(betas[(length(betas)-group.number*24+1):length(betas)])
sdev = as.vector(sqrt(diag(vcov(m.regression)))[(length(betas)-group.number*24+1):length(betas)])

# Plot the grouped intercepts over time for each latent class


condition = c(rep("latent class 1" , 24) , rep("latent class 2" , 24),rep("latent class 3" , 24), rep("latent class 4" , 24))
#specie = c("Quarter 1","Quarter 2","Quarter 3","Quarter 4" )
specie = 1:24
value = avg
sd = sdev
bars = data.frame(specie,condition,value, sdev)


print(ggplot(bars, aes(x=specie, y=avg, fill= condition)) +
        geom_bar(position=position_dodge(), stat="identity", colour='black') +
        geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=.2,position=position_dodge(.9)) +
        ggtitle("Plot: Diary Latent Classes") +
        xlab("month") + ylab("grouped baseline intercept")+
        theme_bw())












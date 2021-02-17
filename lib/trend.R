#This is a prediction model that tries to predict how COVID cases are changing
#It does one short term linear regression, one long term linear regression,
#and a polynomial regression, then to predict the next week, it takes a 
#an average of the three models, weighted by their R.squared value.

library(numDeriv)
trend = function(df,data){
  #df should be whole dataframe
  #column should be of form df$PCTPOS_10027
  recent = data[(nrow(df)-4):nrow(df),]
  long = data[(nrow(df)-10):nrow(df),]
  lin1 = lm(recent~c(1,2,3,4,5))
  lin2 = lm(long~c(1,2,3,4,5,6,7,8,9,10,11))
  r1 = summary(lin1)$r.squared
  r2 = summary(lin2)$r.squared
  slope1 = summary(lin1)$coef[2]
  slope2 = summary(lin2)$coef[2]
  
  poly <- lm(data[1:nrow(df),]~poly(seq(1,nrow(df)),3,raw=TRUE))
  
  f = function(x) poly$coefficients[4]*x^3 + poly$coefficients[3]*x^2 + poly$coefficients[2]*x + poly$coefficients[1]
  slope3 = grad(f, nrow(df))
  r3 = summary(poly)$r.squared
  
  norm = r1 + r2 + r3
  ensemble = slope1 * (r1/norm) + slope2 * (r2/norm) + slope3 * (r3/norm)
  return(ensemble)
}

library(HSAUR3)
library("KernSmooth")
library("flexmix")
library("boot")


## Old Faithful Data
head(faithful)
## Motivation: Histogram
par(mfrow = c(1,2))
hist(faithful$eruptions, breaks = 20, freq = FALSE, main = "Eruptions", xlab = "")
hist(faithful$waiting, breaks = 20, freq  = FALSE, main = "Waiting time", xlab = "")


## Two-dimensional density smoothScatter
par(mfrow = c(1,2))
plot(faithful);  smoothScatter(faithful)




## Code for Histograms 
scatterhist = function(x, y, xlab="", ylab=""){
  zones=matrix(c(2,0,1,3), ncol=2, byrow=TRUE)
  layout(zones, widths=c(4/5,1/5), heights=c(1/5,4/5))
  xhist = hist(x, plot=FALSE)
  yhist = hist(y, plot=FALSE)
  top = max(c(xhist$counts, yhist$counts))
  par(mar=c(3,3,1,1))
  plot(x,y)
  par(mar=c(0,3,1,1))
  barplot(xhist$counts, axes=FALSE, ylim=c(0, top), space=0)
  par(mar=c(3,0,1,1))
  barplot(yhist$counts, axes=FALSE, xlim=c(0, top), space=0, horiz=TRUE)
  par(oma=c(3,3,0,0))
  mtext(xlab, side=1, line=1, outer=TRUE, adj=0, 
    at=.8 * (mean(x) - min(x))/(max(x)-min(x)))
  mtext(ylab, side=2, line=1, outer=TRUE, adj=0, 
    at=(.8 * (mean(y) - min(y))/(max(y) - min(y))))
}


#Code from http://www.r-bloggers.com/example-8-41-scatterplot-with-marginal-histograms/

## Histograms

scatterhist(faithful[,1], faithful[,2])


## Just for fun combine both (Density and histograms)


scatterhist2 = function(x, y, xlab="", ylab=""){
  zones=matrix(c(2,0,1,3), ncol=2, byrow=TRUE)
  layout(zones, widths=c(4/5,1/5), heights=c(1/5,4/5))
  xhist = hist(x, plot=FALSE)
  yhist = hist(y, plot=FALSE)
  top = max(c(xhist$counts, yhist$counts))
  par(mar=c(3,3,1,1))
  ##
  smoothScatter(x,y)
  points(x,y, col="red", pch=16)
  ##
  par(mar=c(0,3,1,1))
  barplot(xhist$counts, axes=FALSE, ylim=c(0, top), space=0)
  par(mar=c(3,0,1,1))
  barplot(yhist$counts, axes=FALSE, xlim=c(0, top), space=0, horiz=TRUE)
  par(oma=c(3,3,0,0))
  mtext(xlab, side=1, line=1, outer=TRUE, adj=0, 
    at=.8 * (mean(x) - min(x))/(max(x)-min(x)))
  mtext(ylab, side=2, line=1, outer=TRUE, adj=0, 
    at=(.8 * (mean(y) - min(y))/(max(y) - min(y))))
}


## Just for fun: combine both (Density and histograms)

scatterhist2(faithful[,1], faithful[,2])



##DE-kernel figures

rec <- function(x) (abs(x) < 1) * 0.5
tri <- function(x) (abs(x) < 1) * (1 - abs(x))
gauss <- function(x) 1/sqrt(2*pi) * exp(-(x^2)/2)
x <- seq(from = -3, to = 3, by = 0.001)
plot(x, rec(x), type = "l", ylim = c(0,1), lty = 1, 
     ylab = expression(K(x)))
lines(x, tri(x), lty = 2)
lines(x, gauss(x), lty = 3)
legend(-3, 0.8, legend = c("Rectangular", "Triangular", 
       "Gaussian"), lty = 1:3, title = "kernel functions", 
       bty = "n")


##DE-kernel figures


w <- options("width")$w
options(width = 66)

x <- c(0, 1, 1.1, 1.5, 1.9, 2.8, 2.9, 3.5)
n <- length(x)
xgrid <- seq(from = min(x) - 1, to = max(x) + 1, by = 0.01) 
h <- 0.4
bumps <- sapply(x, function(a) gauss((xgrid - a)/h)/(n * h))

plot(xgrid, rowSums(bumps), ylab = expression(hat(f)(x)),
     type = "l", xlab = "x", lwd = 2)
rug(x, lwd = 2)
out <- apply(bumps, 2, function(b) lines(xgrid, b))








## Code used to produce above plot
x <- c(0, 1, 1.1, 1.5, 1.9, 2.8, 2.9, 3.5)
n <- length(x)
xgrid <- seq(from = min(x) - 1, to = max(x) + 1, by = 0.01) 
h <- 0.8
bumps <- sapply(x, function(a) tri((xgrid - a)/h)/(n * h))
plot(xgrid, rowSums(bumps), ylab = expression(hat(f)(x)),
     type = "l", xlab = "x", lwd = 2)
rug(x, lwd = 2)
out <- apply(bumps, 2, function(b) lines(xgrid, b))



## DE-faithful-density
#Three kernels with bandwidth = 12 - Page 158

data("faithful", package = "datasets")
x <- faithful$waiting
layout(matrix(1:3, ncol = 3))
hist(x, xlab = "Waiting times (in min.)", ylab = "Frequency",
     probability = TRUE, main = "Gaussian kernel", 
     border = "gray")
lines(density(x, width = 12), lwd = 2)
rug(x)
hist(x, xlab = "Waiting times (in min.)", ylab = "Frequency",
     probability = TRUE, main = "Rectangular kernel", 
     border = "gray")
lines(density(x, width = 12, window = "rectangular"), lwd = 2)
rug(x)
hist(x, xlab = "Waiting times (in min.)", ylab = "Frequency",
     probability = TRUE, main = "Triangular kernel", 
     border = "gray")
lines(density(x, width = 12, window = "triangular"), lwd = 2)
rug(x)



## Bandwidth Choice



## Bandwidth choice

library(benchden)  # load special distributions

#----------------------------------------------------------------
# Sample 
#----------------------------------------------------------------
num = 22            # distribution number (from benchden package)
set.seed(100)
n = 100
x = rberdev(n,num)  # generate sample of size n
truedens <- function(x) dberdev(x,dnum=num)  # true density

par(mfrow=c(2,3))
plot(c(-3,3),c(0,.5),typ='n',xlab='x',ylab='density',las=1)
bw = .5
title(paste("Gaussian kernel, bw =",bw))
grid()
lines(density(x,width=bw,kernel='gaussian'))
rug(x)
curve(truedens,-3,3,add=TRUE,col=4,lwd=1)
legend("topleft", col = 4, lwd = 1, "True density", bty = "n")

plot(c(-3,3),c(0,.5),typ='n',xlab='x',ylab='density',las=1)
bw = 1
title(paste("Gaussian kernel, bw =",bw))
grid()
lines(density(x,width=bw,kernel='gaussian'))
rug(x)
curve(truedens,-3,3,add=TRUE,col=4,lwd=1)
legend("topleft", col = 4, lwd = 1, "True density", bty = "n")

plot(c(-3,3),c(0,.5),typ='n',xlab='x',ylab='density',las=1)
bw = 5
title(paste("Gaussian kernel, bw =",bw))
grid()
lines(density(x,width=bw,kernel='gaussian'))
rug(x)
curve(truedens,-3,3,add=TRUE,col=4,lwd=1)
legend("topleft", col = 4, lwd = 1, "True density", bty = "n")

plot(c(-3,3),c(0,.5),typ='n',xlab='x',ylab='density',las=1)
bw = .5
title(paste("Triangular kernel, bw =",bw))
grid()
lines(density(x,width=bw,kernel='triangular'))
rug(x)
curve(truedens,-3,3,add=TRUE,col=4,lwd=1)
legend("topleft", col = 4, lwd = 1, "True density", bty = "n")

plot(c(-3,3),c(0,.5),typ='n',xlab='x',ylab='density',las=1)
bw = 1
title(paste("Triangular kernel, bw =",bw))
grid()
lines(density(x,width=bw,kernel='triangular'))
rug(x)
curve(truedens,-3,3,add=TRUE,col=4,lwd=1)
legend("topleft", col = 4, lwd = 1, "True density", bty = "n")

plot(c(-3,3),c(0,.5),typ='n',xlab='x',ylab='density',las=1)
bw = 5
title(paste("Triangular kernel, bw =",bw))
grid()
lines(density(x,width=bw,kernel='triangular'))
rug(x)
curve(truedens,-3,3,add=TRUE,col=4,lwd=1)
legend("topleft", col = 4, lwd = 1, "True density", bty = "n")

par(mfrow=c(1,1))

##CYGOB1
 

data(CYGOB1)
head(CYGOB1)
summary(CYGOB1)


##CYGOB1



smoothScatter(CYGOB1,nbin = 10, bandwidth = c(.2, .5))
points(CYGOB1, pch=16, col="red")

## Epanechnikov kernel 

###################################################
### code chunk number 11: DE-epakernel-fig
###################################################
epa <- function(x, y) 
    ((x^2 + y^2) < 1) * 2/pi * (1 - x^2 - y^2)
x <- seq(from = -1.1, to = 1.1, by = 0.05)
epavals <- sapply(x, function(a) epa(a, x))
persp(x = x, y = x, z = epavals, xlab = "x", ylab = "y", 
      zlab = expression(K(x, y)), theta = -35, 
      axes = TRUE, box = TRUE)





## 2-D DE-kernel figures

library("KernSmooth")
data("CYGOB1", package = "HSAUR3")
CYGOB1d <- bkde2D(CYGOB1, 
          bandwidth = sapply(CYGOB1, dpik))


## 2-D DE-kernel figures


contour(x = CYGOB1d$x1, y = CYGOB1d$x2, z = CYGOB1d$fhat, 
xlab = "log surface temperature",
ylab = "log light intensity")


## 2D DE - kernel figures - add points



contour(x = CYGOB1d$x1, y = CYGOB1d$x2, z = CYGOB1d$fhat, 
xlab = "log surface temperature",
ylab = "log light intensity")
points(CYGOB1, pch=16, col="red")



## Plot


persp(x = CYGOB1d$x1, y = CYGOB1d$x2, z = CYGOB1d$fhat,
        xlab = "log surface temperature",
        ylab = "log light intensity",
        zlab = "estimated density",
        theta = -35, axes = TRUE, box = TRUE)



## A Parametric Density Estimate for the Old Faithful Data


head(faithful, n = 6)





## Old Faithful Data


hist(faithful$waiting,freq = F)
lines(density(faithful$waiting))

## Density function

Density.fun <- function(param, x) {
     d1 <- dnorm(x, mean = param[2], sd = param[3])
     d2 <- dnorm(x, mean = param[4], sd = param[5])
return((param[1] * d1) + ((1 - param[1]) * d2))
}



## Density function

hist(faithful$waiting,freq = F, ylim=c(0, .06))
lines(density(faithful$waiting))

lines(seq(40, 100, .1),Density.fun(c(.6, 55,4, 80, 9), seq(40, 100, .1)), col="red")

lines(seq(40, 100, .1),Density.fun(c(.2, 55,6, 80, 8), seq(40, 100, .1)), col="blue")



## Mixture model fitting 



## Log Likelihood Function for our mixture model

logL <- function(param, x) {
     d1 <- dnorm(x, mean = param[2], sd = param[3])
     d2 <- dnorm(x, mean = param[4], sd = param[5])
-sum(log(param[1] * d1 + (1 - param[1]) * d2)) }


## optim


startparam <- c(p = 0.5, mu1 = 50, sd1 = 3, mu2 = 80, sd2 = 3)
opp <- optim(startparam, logL, x = faithful$waiting, 
             method = "L-BFGS-B",
             lower = c(0.01, rep(1, 4)),
             upper = c(0.99, rep(200, 4)))
opp$par
opp$value



## Density function

hist(faithful$waiting,freq = F, ylim=c(0, .06))
lines(density(faithful$waiting))

lines(seq(40, 100, .1),Density.fun(c(.6, 55,4, 80, 9), seq(40, 100, .1)), col="red")

lines(seq(40, 100, .1),Density.fun(c(.2, 55,6, 80, 8), seq(40, 100, .1)), col="blue")

lines(seq(40, 100, .1),Density.fun(opp$par, seq(40, 100, .1)), col="green", lwd=4)


## Density function

faithful$waiting[1:10]
tmp.vals=NULL
for (i in c(.0001, .000001, .00000001, .00000000001)){
pm.pars=c(.5, 79, i, 
            mean(faithful$waiting), sd(faithful$waiting))
tmp.vals=c(tmp.vals, logL(pm.pars, faithful$waiting))
}
opp$value
tmp.vals



## Density function

hist(faithful$waiting,freq = F, ylim=c(0, .06))
rug(faithful$waiting)


lines(seq(40, 100, .1),Density.fun(opp$par, seq(40, 100, .1)), col="green", lwd=4)

lines(seq(40, 100, .1),Density.fun(pm.pars, seq(40, 100, .1)), col="purple", lwd=4)




## cdf.fun for a check

cdf.fun <- function(param, x) {
     d1 <- pnorm(x, mean = param[2], sd = param[3])
     d2 <- pnorm(x, mean = param[4], sd = param[5])
return((param[1] * d1) + ((1 - param[1]) * d2))
}


## CDF plots : Check

plot(ecdf(faithful$waiting))
lines(seq(40, 100, .1),cdf.fun(opp$par, seq(40, 100, .1)), col="green", lwd=2)
lines(seq(40, 100, .1),cdf.fun(pm.pars, seq(40, 100, .1)), col="purple", lwd=2)




## MCLUST


library("mclust")
mc <- Mclust(faithful$waiting)
mc


## Mclust


summary(mc)


## Mclust

mc$parameters$mean
sqrt(mc$parameters$variance$sigmasq)
opp$par


## Mclust

par(mfrow = c(2,2))
plot(mc)


## Flexmix (Page 161)


library("flexmix")
fl <- flexmix(waiting ~ 1, data = faithful, k = 2)
summary(fl)
opp$par



## Bootstrap page 163



library("boot")
fit <- function(x, indx) {
    a <- Mclust(x[indx], minG = 2, maxG = 2, 
                modelNames="E")$parameters
    if (a$pro[1] < 0.5)
        return(c(p = a$pro[1], mu1 = a$mean[1], 
                               mu2 = a$mean[2]))
    return(c(p = 1 - a$pro[1], mu1 = a$mean[2], 
                               mu2 = a$mean[1]))
}



## Bootstrap page 163




bootpara <- boot(faithful$waiting, fit, R = 1000)
boot.ci(bootpara, type = "bca", index = 1)



## Bootstrap page 163


boot.ci(bootpara, type = "bca", index = 2)


## Bootstrap page 163


boot.ci(bootpara, type = "bca", index = 2)



## Bootstrap page 163


boot.ci(bootpara, type = "bca", index = 1)



## Bootstrap page 164


bootplot <- function(b, index, main = "") {
    dens <- density(b$t[,index])
    ci <- boot.ci(b, type = "bca", index = index)$bca[4:5]
    est <- b$t0[index]
    plot(dens, main = main)
    y <- max(dens$y) / 10
    segments(ci[1], y, ci[2], y, lty = 2)
    points(ci[1], y, pch = "(")
    points(ci[2], y, pch = ")")
    points(est, y, pch = 19)
}



## Bootstrap page 165



layout(matrix(1:2, ncol = 2))
bootplot(bootpara, 2, main = expression(mu[1]))
bootplot(bootpara, 3, main = expression(mu[2]))




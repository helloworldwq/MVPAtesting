# Matrix trace
tr <- function(A) sum(diag(A))

# Gaussian univariate kernel
gauss <- function(x,y) dnorm(x-y)





# One group multivariate test for location from
# Srivastava, Muni S., and Meng Du. 
# "A Test for the Mean Vector with Fewer Observations than the Dimension." 
# Journal of Multivariate Analysis 99, no. 3 (March 2008): 386-402. 
t2008 <- function(x){
  delta <- colMeans(x)
  S <- cov(x)
  D <- diag(S)
  D.inv <- diag(1/D)
  n <- nrow(x)
  n1 <- n-1
  R <- cor(x)
  p <- ncol(x)
  tr.R2 <- tr(R %*% R)
  d <- 1+ tr.R2/p^(3/2)
  
  nominator <- n * delta %*% D.inv %*% delta - n1 * p/(n1-2)
  denominator <- sqrt( 2* d *(tr.R2-p^2/n1))
  c(nominator/denominator)
}
## Testing
# .p <- 1e1
# .n <- 1e2
# # debug(t2008)
# t2008(rmvnorm(.n, rep(0,.p)))


# Two group multivariate test for location in 
# Srivastava, Muni S., Shota Katayama, and Yutaka Kano.
# "A Two Sample Test in High Dimensional Data."
# Journal of Multivariate Analysis 114 (February 2013): 349-58. 
t2013 <- function(x,y){
  x.bar <- colMeans(x)
  y.bar <- colMeans(y)
  delta <- x.bar - y.bar
  
  Sx <- cov(x)
  Sy <- cov(y)
  
  nx <- nrow(x)
  ny <- nrow(y)
  n <- nx + ny
  nx1 <- nx-1
  ny1 <- ny-1
  n1 <- n-2
  
  S <- (nx1*Sx + ny1*Sy)/n1
  
  D <- diag(S)
  D.inv <- if(length(D)>1) diag(1/D) else 1/D
  
  R <- sqrt(D.inv) %*% S %*% sqrt(D.inv)
  # R <- cor(rbind(x,y))
  p <- ncol(x)
  tr.R2 <- tr(R %*% R)
  d <- 1 + tr.R2/p^(3/2)
  
  nominator <- 1/(1/nx+1/ny) * delta %*% D.inv %*% delta - p
  denominator <- sqrt( 2 * d *(tr.R2 - p^2/n1))
  c(nominator/denominator)
  # list(nom=nominator, den=denominator, t=nominator/denominator)
}
## Testing:
# .p <- 1e0
# .nx <- 1e1
# .ny <- 1e1
# .x <- rmvnorm(.nx, rep(0,.p))
# .y <- rmvnorm(.ny, rep(0,.p))
# t2013(.x,.y)




# Two group multivariate Behrnes-Fisher problem
# Srivastava, Muni S., Shota Katayama, and Yutaka Kano.
# "A Two Sample Test in High Dimensional Data."
# Journal of Multivariate Analysis 114 (February 2013): 349-58. 
t2013Behrnes <- function(x,y){
  x.bar <- colMeans(x)
  y.bar <- colMeans(y)
  delta <- x.bar - y.bar
  
  nx <- nrow(x)
  ny <- nrow(y)
  n <- nx + ny
  nx1 <- nx-1
  ny1 <- ny-1
  n1 <- n-2
  p <- ncol(x)
  
  Sx <- cov(x)
  Sy <- cov(y)
  S <- 1/nx * Sx + 1/ny * Sy
  
  Dx <- diag(Sx)
  Dy <- diag(Sy)
  D <- 1/nx * Dx + 1/ny * Dy
  D.inv <- diag(1/D)
  
  R <- sqrt(D.inv) %*% S %*% sqrt(D.inv)
  
  tr.R2 <- tr(R %*% R)
  d <- 1 + tr.R2/p^2
  
  sigma <- 2* (tr.R2- 1/(nx1* nx^2) * tr(D.inv %*% Sx)^2 - 1/(ny1* ny^2) * tr(D.inv %*% Sy)^2 )
  
  nominator <- delta %*% D.inv %*% delta - p
  denominator <- sqrt( d * sigma)
  nominator/denominator
}
## Testing:
# .p <- 1e1
# .nx <- 1e1
# .ny <- 1e3
# .x <- rmvnorm(.nx, rep(0,.p))
# .y <- rmvnorm(.ny, rep(0,.p))
# # debug(t2013)
# t2013Behrnes(.x,.y)




hotelling1 <- function(X){
  delta <- colMeans(X)
  
  n <- nrow(X)
  n1 <- n-1
  p <- ncol(X)
  
  S <- cov(X)
  
  S.inv <- solve(S)
  
  n * delta %*% S.inv %*% delta
}
## Testing:
# .p <- 1e1
# .nx <- 1e2
# .x <- rmvnorm(.nx, rep(0,.p))
# hotelling1(.x)






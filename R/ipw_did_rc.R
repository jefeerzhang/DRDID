#' @import stats
NULL
###################################################################################
# Abadie's IPW DID estimator

#' Inverse probability weighted Difference-in-Differences Estimator with Repeated Cross Section  Data
#'
#'
#' @param y An \eqn{n} x \eqn{1} vector of outcomes from the both pre and post-treatment periods.
#' @param post An \eqn{n} x \eqn{1} vector of Post-Treatment dummies (post = 1 if observation belongs to post-tretment period,
#'             and post = 0 if observation belongs to pre-treatment period.)
#' @param D An \eqn{n} x \eqn{1} vector of Group indicators (=1 if observation is treated in the post-treatment, =0 otherwise).
#' @param covariates An \eqn{n} x \eqn{k} matrix of covariates to be used in the propensity score estimation
#' @param i.weights An \eqn{n} x \eqn{1} vector of weights to be used. If NULL, then every observation has the same weights.
#' @param boot Logical argument to whether bootstrap should be used for inference. Default is FALSE.
#' @param boot.type Type of bootstrap to be performed (not relevant if boot = FALSE). Options are "weighted" and "multiplier".
#' If boot==T, default is "weighted".
#' @param nboot Number of bootstrap repetitions (not relevant if boot = FALSE). Default is 999 if boot = TRUE.
#' @param inffunc Logical argument to whether influence function should be returned. Default is FALSE.
#'
#' @return A list containing the following components:
#' \item{ATT}{The IPW DID pointestimate.}
#' \item{se}{ The IPW DID standard error}
#' \item{uci}{Estimate of the upper boudary of a 95\% CI for the ATT}
#' \item{lci}{Estimate of the lower boudary of a 95\% CI for the ATT}
#' \item{boots}{All Bootstrap draws of the ATT, in case bootstrap was used to conduct inference. Default is NULL}
#' \item{att.inf.func}{Estimate of the influence function. Default is NULL}
#' @export

ipw_did_rc <-function(y, post, D, covariates,
                      i.weights = NULL,
                      boot = F,
                      boot.type = "weighted",
                      nboot = NULL,
                      inffunc = F){
  #-----------------------------------------------------------------------------
  # D as vector
  D <- as.vector(D)
  # Sample size
  n <- length(D)
  # y as vector
  y <- as.vector(y)
  # post as vector
  post <- as.vector(post)
  # Add constant to covariate vector
  int.cov <- as.matrix(cbind(1, covariates))

  # Weights
  if(is.null(i.weights)) {
    i.weights <- as.vector(rep(1, n))
  } else if(min(i.weights) < 0) stop("i.weights must be non-negative")
  #-----------------------------------------------------------------------------
  #Pscore estimation (logit) and also its fitted values
  PS <- suppressWarnings(stats::glm(D ~ -1 + int.cov, family = "binomial", weights = i.weights))
  ps.fit <- as.vector(PS$fitted.values)
  # Do not divide by zero
  ps.fit <- pmin(ps.fit, 1 - 1e-16)
  #-----------------------------------------------------------------------------
  #Compute IPW estimator
  # First, the weights
  w.treat.pre <- i.weights * D * (1 - post)
  w.treat.post <- i.weights * D * post
  w.cont.pre <- i.weights * ps.fit * (1 - D) * (1 - post) / (1 - ps.fit)
  w.cont.post <- i.weights * ps.fit * (1 - D) * post/ (1 - ps.fit)

  Pi.hat <- mean(i.weights * D)
  lambda.hat <- mean(i.weights * post)
  one.minus.lambda.hat <- mean(i.weights * (1 - post))

  # Elements of the influence function (summands)
  eta.treat.pre <- w.treat.pre * y / (Pi.hat * one.minus.lambda.hat)
  eta.treat.post <- w.treat.post * y / (Pi.hat * lambda.hat)
  eta.cont.pre <- w.cont.pre * y / (Pi.hat * one.minus.lambda.hat)
  eta.cont.post <- w.cont.post * y / (Pi.hat * lambda.hat)

  # Estimator of each component
  att.treat.pre <- mean(eta.treat.pre)
  att.treat.post <- mean(eta.treat.post)
  att.cont.pre <- mean(eta.cont.pre)
  att.cont.post <- mean(eta.cont.post)

  # ATT estimator
  ipw.att <- (att.treat.post - att.treat.pre) - (att.cont.post - att.cont.pre)
  #-----------------------------------------------------------------------------
  #get the influence function to compute standard error
  #-----------------------------------------------------------------------------
  # Asymptotic linear representation of logit's beta's
  score.ps <- i.weights * (D - ps.fit) * int.cov
  Hessian.ps <- stats::vcov(PS) * n
  asy.lin.rep.ps <-  score.ps %*% Hessian.ps
  #-----------------------------------------------------------------------------
  # Influence function of the treated components
  inf.treat.post1 <- eta.treat.post - att.treat.post
  inf.treat.post2 <- -(i.weights * D - Pi.hat) * att.treat.post/Pi.hat
  inf.treat.post3 <- -(i.weights * post - lambda.hat) * att.treat.post/lambda.hat
  inf.treat.post <- inf.treat.post1 + inf.treat.post2 + inf.treat.post3

  inf.treat.pre1 <- eta.treat.pre - att.treat.pre
  inf.treat.pre2 <- -(i.weights * D - Pi.hat) * att.treat.pre/Pi.hat
  inf.treat.pre3 <- -(i.weights * (1 - post) - one.minus.lambda.hat) *
    att.treat.pre/one.minus.lambda.hat
  inf.treat.pret <- inf.treat.pre1 + inf.treat.pre2 + inf.treat.pre3

  # Now, get the influence function of control component
  # First, terms of the inf. funct as if pscore was known
  inf.cont.post1 <- eta.cont.post - att.cont.post
  inf.cont.post2 <- -(i.weights * D - Pi.hat) * att.cont.post/Pi.hat
  inf.cont.post3 <- -(i.weights * post - lambda.hat) * att.cont.post/lambda.hat
  inf.cont.post <- inf.cont.post1 + inf.cont.post2 + inf.cont.post3

  inf.cont.pre1 <- eta.cont.pre - att.cont.pre
  inf.cont.pre2 <- -(i.weights * D - Pi.hat) * att.cont.pre/Pi.hat
  inf.cont.pre3 <- -(i.weights * (1 - post) - one.minus.lambda.hat) *
    att.cont.pre/one.minus.lambda.hat
  inf.cont.pret <- inf.cont.pre1 + inf.cont.pre2 + inf.cont.pre3

  # Estimation effect from the propensity score parametes
  # Derivative matrix (k x 1 vector)
  mom.logit.pre <- -eta.cont.pre * int.cov
  mom.logit.pre <- base::colMeans(mom.logit.pre)

  mom.logit.post <- -eta.cont.post * int.cov
  mom.logit.post <- base::colMeans(mom.logit.post)

  # Now the influence function related to estimation effect of pscores
  inf.logit <- asy.lin.rep.ps %*% (mom.logit.post - mom.logit.pre)
  #get the influence function of the DR estimator (put all pieces together)
  att.inf.func <- (inf.treat.post - inf.treat.pret) - (inf.cont.post - inf.cont.pret) +
    inf.logit
  #-----------------------------------------------------------------------------
  if (boot == F) {
    # Estimate of standard error
    se.att <- stats::sd(att.inf.func)/sqrt(n)
    # Estimate of upper boudary of 95% CI
    uci <- ipw.att + 1.96 * se.att
    # Estimate of lower doundary of 95% CI
    lci <- ipw.att - 1.96 * se.att

    #Create this null vector so we can export the bootstrap draws too.
    ipw.boot <- NULL
  }
  if (boot == T) {
    if (is.null(nboot) == T) nboot = 999
    if(boot.type == "multiplier"){
      # do multiplier bootstrap
      ipw.boot <- mboot.did(att.inf.func, nboot)
      # get bootstrap std errors based on IQR
      se.att <- stats::IQR(ipw.boot) / (stats::qnorm(0.75) - stats::qnorm(0.25))
      # get symmtric critival values
      cv <- stats::quantile(abs(ipw.boot/se.att), probs = 0.95)
      # Estimate of upper boudary of 95% CI
      uci <- ipw.att + cv * se.att
      # Estimate of lower doundary of 95% CI
      lci <- ipw.att - cv * se.att
    } else {
      # do weighted bootstrap
      ipw.boot <- unlist(lapply(1:nboot, wboot_ipw_rc,
                                n = n, y = y, post = post, D = D, int.cov = int.cov, i.weights = i.weights))
      # get bootstrap std errors based on IQR
      se.att <- stats::IQR((ipw.boot - ipw.att)) / (stats::qnorm(0.75) - stats::qnorm(0.25))
      # get symmtric critival values
      cv <- stats::quantile(abs((ipw.boot - ipw.att)/se.att), probs = 0.95)
      # Estimate of upper boudary of 95% CI
      uci <- ipw.att + cv * se.att
      # Estimate of lower doundary of 95% CI
      lci <- ipw.att - cv * se.att

    }

  }
  if(inffunc==F) att.inf.func <- NULL

  return(list(ATT = ipw.att,
              se = se.att,
              uci = uci,
              lci = lci,
              boots = ipw.boot,
              att.inf.func = att.inf.func))
}

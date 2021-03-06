# DRDID: Doubly Robust Difference-in-Differences.

## Overview 


This `R` package implements different DID procedures to estimate the ATT under the conditional parallel trends assumption, including a regression-based DID estimator in the spirit of Heckman, Ichimura and Todd (1997), the inverse probabily weigthed (IPW) DID estimator proposed by Abadie (2005), and the doubly robust (DR) DID estimators proposed
by Sant'Anna and Zhao (2019), [Doubly Robust Difference-in-Differences Estimators](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3293315).


On one hand, the regression DID estimator requires the regression model for the evolution of the potential outcomes for the comparison group to be correctly specified. On the other hand, the IPW DID estimator requires that the conditional probability of being in the treated group (the propensity score) is correctly specified. By noticing that these DID estimators rely on different, non-nested assumptions, [Sant'Anna and Zhao (2019)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3293315) propose to combine them in a particular way such that the resulting DID estimators remain consistent if either (but not necessarily both) the outcome regression or the propensity score model is correctly specified. In addition, the DR DID estimators proposed by [Sant'Anna and Zhao (2019)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3293315) attain the semiparametric efficiency bound when both the outcome regression and propensity score models are correctly specified.


As discussed in [Sant'Anna and Zhao (2019)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3293315), a researcher can construct different DR DID estimators depending on how he/she estimates the nuisance functions. The `DRDID` package implements two DR DID estimators when panel data are available, and four DR DID estimators when repeated cross-section data are available:


**PANEL DATA ESTIMATORS**
        
* `drdid_panel` - This implements the "traditional" DR DID estimator proposed in Sant'Anna and Zhao (2019) when panel data are available, where one uses a logistic propensity score model and a linear regression model for the outcome growth of the comparison units. The propensity score parameters are estimated via maximum likelihood, and the outcome regression parameters are estimated via OLS - hence the label "traditional". When both working models are correctly specified, the DR DID estimator is semiparametrically efficient.

* `drdid_imp_panel` - This implements the "improved" DR DID estimator proposed in Sant'Anna and Zhao (2019) when panel data are available. On top of being DR consistent, and locally semiparametrically efficient as the estimator implemented via `drdid_panel`, it is also DR for inference - hence the label "improved". The propensity score parameters are estimated via the inverse probability tilting procedure proposed by Graham, Pinto and Egel (2012), and the outcome regression parameters via weighted least squares.


**REPEATED CROSS-SECTION DATA ESTIMATORS**
        
* `drdid_rc` - This implements the "traditional" DR and locally efficient DID estimator proposed in Sant'Anna and Zhao (2019) when repeated cross-section data are available. This estimator makes use of outcome regressions for both treated and comparison units. Like `drdid_panel`, the propensity score parameters are estimated via maximum likelihood, and the outcome regression parameters are estimated via OLS. 

* `drdid_rc1` - This implements the "Traditional" DR DID estimator proposed in Sant'Anna and Zhao (2019) when repeated cross-section data are available. This estimator makes use of outcome regressions only for the comparison units, though it does not attain the semiparametric efficient bound. Like `drdid_rc`, the propensity score parameters are estimated via maximum likelihood, and the outcome regression parameters are estimated via OLS. 

* `drdid_imp_rc` - This implements the "further improved" DR and locally efficient DID estimator proposed in Sant'Anna and Zhao (2019) when repeated cross-section data are available. This estimator makes use of outcome regressions for both treated and comparison units. Like `drdid_imp_panel`, the propensity score parameters are estimated using the procedure of Graham, Pinto and Egel (2012), and the outcome regression parameters for the comparison units are estimated via weighted least squares. On the other hand, the outcome regression parameters for the treated units are estimated via OLS.

* `drdid_imp_rc1` - This implements the "further improved" DR DID estimator proposed in Sant'Anna and Zhao (2019) when repeated cross-section data are available. This estimator makes use of outcome regressions only for the comparison units, though it does not attain the semiparametric efficient bound. Like `drdid_imp_panel`, the propensity score parameters are estimated using the procedure of Graham, Pinto and Egel (2012), and the outcome regression parameters for the comparison units are estimated via weighted least squares.


For further details, please see the paper Sant'Anna and Zhao (2019), [Doubly Robust Difference-in-Differences Estimators](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3293315). In case you have any comments and/or questions, please contact Pedro Sant'Anna (see email below).

## Installing DRDID
This github website hosts the source code, and it always has the most updated version of the package.

To install the most recent version of the `DRDID` package from GitHub (this is what we recommend):

        library(devtools)
        devtools::install_github("pedrohcgs/DRDID")
        
## Authors 

Pedro H. C. Sant'Anna, Vanderbilt University, Nashville, TN. E-mail: pedro.h.santanna [at] vanderbilt [dot] edu.

Jun B. Zhao, Vanderbilt University, Nashville, TN. E-mail: jun.zhao [at] vanderbilt [dot] edu.


## References

* Abadie, Alberto (2005), "Semiparametric Difference-in-Differences Estimators", The Review of Economic Studies, 72(1), pp. 1-19.

* Graham, Bryan, Pinto, Cristine, and Egel, Daniel (2012), "Inverse Probability Tilting for Moment Condition Models with Missing Data", The Review of Economic Studies, 79(3), pp. 1053-1079.

* Heckman, James J., Ichimura, Hidehiko, and Todd, Petra E. (1997), "Matching as an Econometric Evaluation Estimator: Evidence from Evaluating a Job Training Programme", The Review of Economic Studies, 64(4),pp. 605–654.

* Sant'Anna, Pedro H. and Zhao, Jun B. (2019), ["Doubly Robust Difference-in-Differences Estimators"](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3293315), Working paper.


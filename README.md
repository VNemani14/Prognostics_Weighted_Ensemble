# Opimization-based Ensemble Weighting for Prognostics

This repository contains parts of code for the publication "Degradation-Aware Ensemble of DiversePredictorsfor Remaining Useful Life Prediction" by _Venkat Nemani, Adam Thelen, Chao Hu, and Steve Daining_ submitted to **Journal of Mechanical Design** (JMD) special issue on _Selected IDETC Conference Papers_. 

In this code repository we share 
- Remaning useful life (RUL) prediction of batteries using Exponential Unscented Kalman Filter (EUKF), Gaussian Process Regression (GPR) and Long Short-term Memory (LSTM). Each of these models provide RUL uncertainty quantification at every prediction time step. 
- Ensemble of the individual RUL predictions through 
    (1) simple averaging (En-all)
    (2) degradation independent weighting (DIEn)
    (3) degradation stage dependent weighting (DSDEn)
- Postprocess results.


`Datasets` contains

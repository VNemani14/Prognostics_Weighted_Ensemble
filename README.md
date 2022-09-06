# Opimization-based Ensemble Weighting for Prognostics

This repository contains parts of code for the publication "Degradation-Aware Ensemble of DiversePredictorsfor Remaining Useful Life Prediction" by _Venkat Nemani, Adam Thelen, Chao Hu, and Steve Daining_ submitted to **Journal of Mechanical Design** (JMD) special issue on _Selected IDETC Conference Papers_. The conference paper is titled "Dynamically Weighted Ensemble of Diverse Learners for Remaining Useful Life Prediction" published in **ASME 2022 International Design Engineering Technical Conference** (IDETC), 2022, pp. 1–8

In this code repository we share:
- Remaning useful life (RUL) prediction of batteries using Exponential Unscented Kalman Filter (EUKF), Gaussian Process Regression (GPR) and Long Short-term Memory (LSTM). Each of these models provide RUL uncertainty quantification at every prediction time step. 
- Ensemble of the individual RUL predictions through 

    (1) simple averaging (En-all)
    
    (2) degradation independent weighting (DIEn): [Hu, Chao, et al. "Ensemble of data-driven prognostic algorithms for robust prediction of remaining useful life." Reliability Engineering & System Safety 103 (2012): 120-135.](https://doi.org/10.1016/j.ress.2012.03.008)
    
    (3) degradation stage dependent weighting (DSDEn): [Li, Zhixiong, et al. "An ensemble learning-based prognostic approach with degradation-dependent weights for remaining useful life prediction." Reliability Engineering & System Safety 184 (2019): 110-122.](https://doi.org/10.1016/j.ress.2017.12.016)
    
- Postprocess results in relation to prediction accuracy and uncertainty quantification: root-mean-squarred error (RMSE), weighted RMSE (giving more importance close to end-of-life predictions), alpha accuracy, beta probability and median of negative log likelihood. See image below for visualization of some of the metrics
<p align="center">
<img src="https://user-images.githubusercontent.com/94071944/188748621-f7d73cef-9962-4edc-bf5d-cadb178b3d77.png" alt="drawing" width="300"/>
</p>

## Code description

`Datasets` contains the extracted capacity curves for Li-ion batteries provided by [Severson, Kristen A., et al. "Data-driven prediction of battery cycle life before capacity degradation." Nature Energy 4.5 (2019): 383-391.](https://doi.org/10.1038/s41560-019-0356-8) and [Attia, Peter M., et al. "Closed-loop optimization of fast-charging protocols for batteries with machine learning." Nature 578.7795 (2020): 397-402.](https://doi.org/10.1038/s41586-020-1994-5)
- Contains 1 `.mat` file for training and 3 `.mat` test files for testing



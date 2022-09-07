# Opimization-based Ensemble Weighting for Prognostics

This repository contains parts of the code for the manuscript titled "Degradation-Aware Ensemble of DiversePredictorsfor Remaining Useful Life Prediction" by _Venkat Nemani, Adam Thelen, Chao Hu, and Steve Daining_ submitted to the **Journal of Mechanical Design (JMD)** special issue on _"Selected Papers from IDETC 2022"_. The conference paper is titled "Dynamically Weighted Ensemble of Diverse Learners for Remaining Useful Life Prediction" and was presented at the **ASME 2022 International Design Engineering Technical Conference (ASME IDETC 2022)** on August 16, 2022.

In this code repository we share:
- Remaning useful life (RUL) prediction of lithium-ion batteries using Exponential Unscented Kalman Filter (EUKF), Gaussian Process Regression (GPR) and Long Short-Term Memory (LSTM) Recurrent Neural Network. Each of these models produces an estimation of the RUL prediction uncertainty (i.e., uncertainty quantification) at every prediction time step. 
- Ensemble of the individual RUL predictions through 

    (1) simple averaging (En-all)
    
    (2) degradation-independent weighting (DIEn): [Hu, Chao, et al. "Ensemble of data-driven prognostic algorithms for robust prediction of remaining useful life." Reliability Engineering & System Safety 103 (2012): 120-135.] (https://doi.org/10.1016/j.ress.2012.03.008)
    
    (3) degradation stage-dependent weighting (DSDEn): [Li, Zhixiong, et al. "An ensemble learning-based prognostic approach with degradation-dependent weights for remaining useful life prediction." Reliability Engineering & System Safety 184 (2019): 110-122.] (https://doi.org/10.1016/j.ress.2017.12.016)
    
- Postprocess results in relation to prediction accuracy and quality of uncertainty quantification: root-mean-square error (RMSE), weighted RMSE (giving more importance to predictions at time steps closer to end-of-life), alpha accuracy, beta probability and median of negative log likelihood. See image below for visualization of some of the metrics
<p align="center">
<img src="https://user-images.githubusercontent.com/94071944/188748621-f7d73cef-9962-4edc-bf5d-cadb178b3d77.png" alt="drawing" width="400"/>
</p>

## Code description

`Datasets` contains the extracted capacity fade curves for lithium-ion batteries provided by [Severson, Kristen A., et al. "Data-driven prediction of battery cycle life before capacity degradation." Nature Energy 4.5 (2019): 383-391.] (https://doi.org/10.1038/s41560-019-0356-8) and [Attia, Peter M., et al. "Closed-loop optimization of fast-charging protocols for batteries with machine learning." Nature 578.7795 (2020): 397-402.] (https://doi.org/10.1038/s41586-020-1994-5)
- The folder contains 1 `.mat` file for training and 3 `.mat` test files for testing

`Individual_models` contains the codes for RUL predictions
- `Battery_prognostics_EUKF_and_GPR.m` utilizes EUKF and GPR to make predictions. The code can also plot forecasts at every time step. This main file uses `get_ExpUKFstatesEn_battery.m`, `ukf.m` and `get_GPREn_battery.m` files. Note that the parameters used in this code are not optimized as stated in the paper.

- `LSTM_battery_prognostics.ipynb` for time series forecasting/ RUL prediction using LSTM with a custom Gaussian layer that gives a mean and variance of every next step prediction. The Gaussian layer is inspired from [Lakshminarayanan, Balaji, Alexander Pritzel, and Charles Blundell. "Simple and scalable predictive uncertainty estimation using deep ensembles." Advances in neural information processing systems 30 (2017).] (https://arxiv.org/abs/1612.01474). The `LSTMBatx.mat` files generated from this notebook contain the RUL prediction curves for all batteries in the 4 datasets (1 training dataset and 3 test datasets). 

`ModelEnsemble` folder combines individual model predictions from `Individual_models`
- `Ensemble_models.m` is the main file that determines optimal weights (for DIEn and DSDEn) using thet training dataset and evaluates the corresponding ensemble models on the test datasets. This file uses `Results_EUKF_GPR_LSTM_RUL.mat` which consists of RUL predictions by individual models. This code also plots the RUL for any training/test battery and also plots the calibration curve of observed confidence vs. expected confidence. Sample plots are shown below. 

<p align="center">
  <img src="/ModelEnsemble/RUL_sample.jpg" width="400" />
  <img src="/ModelEnsemble/calibration_sample.jpg" width="400" />
</p>

The calibration curve in the paper is a result of multiple independent runs. 

NOTE: Please contact Venkat Nemani (nemani1401@gmail.com) or Chao Hu (huchaostu@gmail.com) for any queries.

function [TMRindex , reactGains , notReactGains] = getBehav()


%from offlineGains_preprocessing.R
TMRindex = [     48.938963
    12.369090
    4.128610
    1.707437
    -1.678479
    22.493319
    24.907019
    -6.856656
    -13.357949
    -14.511659
    2.791882
    13.724730
    45.767219
    6.136416
    1.371099
    13.041124
    25.375021
    12.006218
    -13.473086
    -4.914205
    7.200441
    -4.489435
    14.420908
    -14.437915 ]; 

reactGains = [ 17.71136973  34.05858412  32.14817219   0.04167532 ...
    14.42537994  21.72953504   2.61396646  33.62848209  -9.73748240  -8.44974713  12.57116576 ...
    22.00232825 -33.80268688 3.59798153  10.39230677  29.35166032  13.23151041  16.95819974 ...
    11.77051794   5.11158980   9.08001297  18.64793652  16.50714297  -0.67169097]; 

notReactGains=  [ -31.2275930  21.6894944  28.0195619  -1.6657614  ...
    16.1038586  -0.7637838 -22.2930525  40.4851377   3.6204665   6.0619116   9.7792841 ...
    8.2775979 -79.5699063  -2.5384345   9.0212074  16.3105365 -12.1435105   4.9519817 ...
    25.2436043  10.0257948   1.8795716  23.1373719   2.0862354  13.7662235];
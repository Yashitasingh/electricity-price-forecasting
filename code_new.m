% Load your dataset (replace 'electricity_price_data.csv' with your data)
data = readtable('C:\Users\Hp\OneDrive\Desktop\electricity_dah_prices2.csv');

% Assuming your dataset has separate 'Date' and 'Hour' columns

% Convert 'Date' to datetime with the format 'dd-MM-yyyy'
data.Date = datetime(data.Date, 'InputFormat', 'dd-MM-yyyy');

% Split the 'Hour' column into 'StartTime' and 'EndTime' based on the hyphen
timePeriods = split(data.Hour, '-');

% Convert 'StartTime' and 'EndTime' to duration
startTime = duration(timePeriods(:, 1), 'InputFormat', 'hh:mm');
endTime = duration(timePeriods(:, 2), 'InputFormat', 'hh:mm');

% Create datetime values for the start and end of the time period
data.StartTime = data.Date + startTime;
data.EndTime = data.Date + endTime;

% Select the 'StartTime' and 'EndTime' columns as the time period and 'Price' for plotting
timestamps = data.StartTime;
prices = data.Price;

% Split the data into training and testing
train_ratio = 0.8;  % 80% for training, 20% for testing
split_idx = round(train_ratio * size(data, 1));

train_timestamps = timestamps(1:split_idx);
train_prices = prices(1:split_idx);
test_timestamps = timestamps(split_idx + 1:end);
test_prices = prices(split_idx + 1:end);

% Choose and configure the ARIMA model
model = arima('D', 1, 'Seasonality', 24, 'MALags', 1, 'SARLags', 24);
model = estimate(model, train_prices);

% Forecast the next timestamp
forecast_horizon = 1;  % Forecast one time step into the future

% Separate the forecasted value from the 'forecast' function
forecasted_price = forecast(model, forecast_horizon, 'Y0', train_prices);

% Extract the actual price for the next timestamp
actual_price = test_prices(1);

% Calculate Mean Absolute Error (MAE)
mae = abs(forecasted_price - actual_price);

% Calculate Mean Squared Error (MSE)
mse = (forecasted_price - actual_price)^2;

% Display the forecasted and actual prices
fprintf('Forecasted Price: %.2f\n', forecasted_price);
fprintf('Actual Price: %.2f\n', actual_price);

% Display the evaluation metrics
fprintf('Mean Absolute Error (MAE): %.2f\n', mae);
fprintf('Mean Squared Error (MSE): %.2f\n', mse);

% Plot actual and forecasted prices
figure;
plot(train_timestamps, train_prices, 'b', 'DisplayName', 'Actual Price (Training)');
hold on;
plot(test_timestamps, test_prices, 'g', 'DisplayName', 'Actual Price (Testing)');
plot(test_timestamps(1), forecasted_price, 'ro', 'DisplayName', 'Forecasted Price');
datetick('x', 'dd-MM-yyyy HH:MM', 'keepticks');
xlabel('Date and Time');
ylabel('Price');
title('Electricity Price Forecasting');
legend('Location', 'best');
grid on;
hold off;
% File Processing and Duration Calculation

% Define input and output filenames
inputFile = '/FOLDER_PATH/Station.txt';  
outputFile = '/FOLDER_PATH/Station_with_Duration.txt';
outputFile_GT5 = '/FOLDER_PATH/Station_Duration_GT5.txt';  % For stations >5 years

% Read the station data using readcell (to properly capture missing text values)
channelData = readcell(inputFile, 'Delimiter', '|', 'NumHeaderLines', 1);

% Convert the cell array to string format
channelData = string(channelData);

% Extract data columns
network    = channelData(:,1);
station    = channelData(:,2);
latitude   = str2double(channelData(:,3));
longitude  = str2double(channelData(:,4));
elevation  = str2double(channelData(:,5));
sitename   = channelData(:,6);
start_time = channelData(:,7);
end_time   = channelData(:,8);

% Ensure end_time is a string array and handle missing values
end_time = string(end_time);  % Convert if not already

% Define replacement values
true_end_date = "2599-12-31T23:59:59";         % For missing EndTime values
duration_calc_end_date = "2025-03-01T16:23:30.0000";  % For duration calculation

% Detect missing EndTime values (including <missing> or whitespace)
missing_idx = ismissing(end_time) | strlength(strtrim(end_time)) == 0;
end_time(missing_idx) = true_end_date;

% Convert StartTime and EndTime to datetime
start_time_dt = datetime(start_time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');
end_time_dt   = datetime(end_time,   'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');

% For duration calculation, if EndTime is missing, use a fixed date
calc_end_time_dt = end_time_dt;
calc_end_time_dt(missing_idx) = datetime(duration_calc_end_date, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');

% Calculate duration in years
duration_years = years(calc_end_time_dt - start_time_dt);

% Create output matrix with same format
outputData = [network, station, channelData(:,3:6), start_time, end_time, string(duration_years)];

% Write the complete data to file
writematrix(outputData, outputFile, 'Delimiter', '|');

% Separate out stations with duration > 5 years
GT5_idx = duration_years > 5;
outputData_GT5 = outputData(GT5_idx, :);
writematrix(outputData_GT5, outputFile_GT5, 'Delimiter', '|');

disp('✅ Station file with durations successfully created!');
disp('✅ Separate file for stations with >5 years duration saved!');

%% Plotting Figures

%% Define a function handle for degree formatting on tick labels
degree_format = @(x) sprintf('%d°', x);

%% Load US State Boundaries
states = shaperead('usastatelo', 'UseGeoCoords', true);

%% Figure 1: All Station Locations with US State Boundaries (Lambert Projection)
figure(1);
ax = axesm('lambert', 'MapLatLimit', [31 41], 'MapLonLimit', [-88 -74], ...
           'Frame', 'on', 'Grid', 'on', 'MeridianLabel', 'on', 'ParallelLabel', 'on');
setm(ax, 'MLineLocation', 2, 'PLineLocation', 2, 'MLabelLocation', 2, 'PLabelLocation', 2);

hold on;

% Plot US state boundaries
geoshow(states, 'DisplayType', 'polygon', 'FaceColor', 'none', ...
        'EdgeColor', 'k', 'LineWidth', 1.5);

% Plot all station locations
h1 = scatterm(latitude, longitude, 50, 'y', '^', 'filled', 'MarkerEdgeColor', 'k');

% Format plot
title('Station availability - RF analysis ');
set(gcf, 'Color', 'w');  
set(gca, 'Box', 'off', 'XColor', 'none', 'YColor', 'none');
grid on

legend(h1, 'Broadband Stations with channels BH & HH - From year 2000-current', 'Location', 'best');
% Count total number of stations
total_stations = numel(latitude);

% Add total station count in southeast corner
textm(32, -78, sprintf('Stations: %d', total_stations), ...
      'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'w', ...
      'EdgeColor', 'k', 'Margin', 5);

hold off;

%% Figure 2: Stations with Duration > 5 Years (Using Lambert Projection)
figure(2);
ax = axesm('lambert', 'MapLatLimit', [31 41], 'MapLonLimit', [-88 -74], ...
           'Frame', 'on', 'Grid', 'on', 'MeridianLabel', 'on', 'ParallelLabel', 'on');
setm(ax, 'MLineLocation', 2, 'PLineLocation', 2, 'MLabelLocation', 2, 'PLabelLocation', 2);

hold on;

% Plot US state boundaries
geoshow(states, 'DisplayType', 'polygon', 'FaceColor', 'none', ...
        'EdgeColor', 'k', 'LineWidth', 1.5);

% Plot only stations with duration > 5 years
h2 = scatterm(latitude(GT5_idx), longitude(GT5_idx), 50, 'r', '^', 'filled', 'MarkerEdgeColor', 'k');
title('Station availability - RF analysis ');
set(gcf, 'Color', 'w');  
set(gca, 'Box', 'off', 'XColor', 'none', 'YColor', 'none');
legend(h2, 'Broadband Stations with channels BH & HH - Duration > 5 Years - From year 2000-current', 'Location', 'best');
% Count total stations with >5 years duration
total_GT5 = sum(GT5_idx);

% Add total station count in southeast corner
textm(32, -78, sprintf('Stations: %d', total_GT5), ...
      'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'w', ...
      'EdgeColor', 'k', 'Margin', 5);

hold off;



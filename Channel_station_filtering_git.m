% Clear workspace
clear; clc; close all;

% Define file paths
inputFile = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel.txt';
outputFileAll = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_WithDuration.txt';
outputFile5Years = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore.txt';
outputFile40Hz = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_40Hz.txt';
outputFile100Hz = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_100Hz.txt';

% Read the Channel file
channelData = readmatrix(inputFile, 'Delimiter', '|', 'NumHeaderLines', 1, 'OutputType', 'string');

% Extract relevant columns
stations = channelData(:, 2);  % Station names
networks = channelData(:, 1);  % Network names
channels = channelData(:, 4);  % Channel names
uniqueStationIDs = strcat(networks, '|', stations);  % Combine Network & Station to ensure uniqueness
startTime = datetime(channelData(:, 16), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');
endTime = datetime(channelData(:, 17), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');
samplingRates = str2double(channelData(:, 15)); % Extract sampling rate column

% Compute duration in days and convert to years
durationDays = days(endTime - startTime);
durationYears = durationDays / 365.25;

% Convert duration to string for writing
durationStr = string(round(durationYears, 2)); % Round to 2 decimal places

% Add the duration column to the original dataset
channelDataWithDuration = [channelData, durationStr];

% Save the updated dataset with duration column
% writematrix(channelDataWithDuration, outputFileAll, 'Delimiter', '|');
fprintf('Saved full dataset with duration column to: %s\n', outputFileAll);

% **Filter for "5 or more years" only**
filter5Years = durationYears >= 5;
channelData5Years = channelDataWithDuration(filter5Years, :);

% Save only "5 or more years" data
writematrix(channelData5Years, outputFile5Years, 'Delimiter', '|');
fprintf('Saved filtered dataset (5 or more years) to: %s\n', outputFile5Years);

% **Filter "5+ years" dataset by sampling rate (40 Hz and 100 Hz)**
samplingRates5Years = str2double(channelData5Years(:, 15));
channels5Years = channelData5Years(:, 4);  % Channel names
stations5Years = channelData5Years(:, 2);  % Station names

% **40 Hz Filter**
filter40Hz = samplingRates5Years == 40;
channelData40Hz = channelData5Years(filter40Hz, :);
uniqueChannels40Hz = unique(channels5Years(filter40Hz));
uniqueStations40Hz = unique(stations5Years(filter40Hz));
writematrix(channelData40Hz, outputFile40Hz, 'Delimiter', '|');
fprintf('Saved 40 Hz dataset (5+ years) to: %s\n', outputFile40Hz);

% **100 Hz Filter**
filter100Hz = samplingRates5Years == 100;
channelData100Hz = channelData5Years(filter100Hz, :);
uniqueChannels100Hz = unique(channels5Years(filter100Hz));
uniqueStations100Hz = unique(stations5Years(filter100Hz));
writematrix(channelData100Hz, outputFile100Hz, 'Delimiter', '|');
fprintf('Saved 100 Hz dataset (5+ years) to: %s\n', outputFile100Hz);

% **Print summary statistics**
num40Hz = sum(filter40Hz);
num100Hz = sum(filter100Hz);

fprintf('\nSummary of 5+ Years Channels:\n');
fprintf('-----------------------------------------\n');
fprintf('40 Hz Channels Count: %d\n', num40Hz);
fprintf('Unique 40 Hz Channels: %d\n', length(uniqueChannels40Hz));
fprintf('Unique 40 Hz Stations: %d\n', length(uniqueStations40Hz));
fprintf('40 Hz Channel Names: %s\n', strjoin(uniqueChannels40Hz, ', '));

fprintf('\n100 Hz Channels Count: %d\n', num100Hz);
fprintf('Unique 100 Hz Channels: %d\n', length(uniqueChannels100Hz));
fprintf('Unique 100 Hz Stations: %d\n', length(uniqueStations100Hz));
fprintf('100 Hz Channel Names: %s\n', strjoin(uniqueChannels100Hz, ', '));

%___________________________________________



% ✅ Define file paths for 40Hz and 100Hz data
inputFile40Hz = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_40Hz.txt';
inputFile100Hz = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_100Hz.txt';

% ✅ Read 40 Hz Data
channelData40Hz = readmatrix(inputFile40Hz, 'Delimiter', '|', 'OutputType', 'string');
latitude40Hz = str2double(channelData40Hz(:, 5));
longitude40Hz = str2double(channelData40Hz(:, 6));
stations40Hz = channelData40Hz(:, 2); % Station names

% ✅ Read 100 Hz Data
channelData100Hz = readmatrix(inputFile100Hz, 'Delimiter', '|', 'OutputType', 'string');
latitude100Hz = str2double(channelData100Hz(:, 5));
longitude100Hz = str2double(channelData100Hz(:, 6));
stations100Hz = channelData100Hz(:, 2); % Station names

%_________________________________________________________________
figure(1);
 
%% Define a function handle for degree formatting on tick labels
degree_format = @(x) sprintf('%d°', x);

%% Load US State Boundaries
states = shaperead('usastatelo', 'UseGeoCoords', true);

ax = axesm('lambert', 'MapLatLimit', [31 41], 'MapLonLimit', [-88 -74], ...
           'Frame', 'on', 'Grid', 'on', 'MeridianLabel', 'on', 'ParallelLabel', 'on');
setm(ax, 'MLineLocation', 2, 'PLineLocation', 2, 'MLabelLocation', 2, 'PLabelLocation', 2);

hold on;

% Plot US state boundaries
geoshow(states, 'DisplayType', 'polygon', 'FaceColor', 'none', ...
        'EdgeColor', 'k', 'LineWidth', 1.5);
hold on;
% Plot 40Hz station locations
h1 = scatterm(latitude40Hz,longitude40Hz, 60, 'r', '^', 'filled', 'MarkerEdgeColor', 'k');

for i = 1:length(stations40Hz)
    textm(latitude40Hz(i) + 0.1, longitude40Hz(i) + 0.15, stations40Hz{i}, ...
          'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b');
end


% Format plot
title('Station availability - RF analysis ');
set(gcf, 'Color', 'w');  
set(gca, 'Box', 'off', 'XColor', 'none', 'YColor', 'none');
grid on

legend(h1, 'Broadband Stations with 40 Hz channels - From year 1996-current / 5+ years duration', 'Location', 'best');

hold off;

%_________________________________________________________________
figure(2);
 
%% Define a function handle for degree formatting on tick labels
degree_format = @(x) sprintf('%d°', x);

%% Load US State Boundaries
states = shaperead('usastatelo', 'UseGeoCoords', true);

ax = axesm('lambert', 'MapLatLimit', [31 41], 'MapLonLimit', [-88 -74], ...
           'Frame', 'on', 'Grid', 'on', 'MeridianLabel', 'on', 'ParallelLabel', 'on');
setm(ax, 'MLineLocation', 2, 'PLineLocation', 2, 'MLabelLocation', 2, 'PLabelLocation', 2);

hold on;

% Plot US state boundaries
geoshow(states, 'DisplayType', 'polygon', 'FaceColor', 'none', ...
        'EdgeColor', 'k', 'LineWidth', 1.5);
hold on;
% Plot 40Hz station locations
h1 = scatterm(latitude100Hz,longitude100Hz, 60, 'y', '^', 'filled', 'MarkerEdgeColor', 'k');

for i = 1:length(stations100Hz)
    textm(latitude100Hz(i) + 0.1, longitude100Hz(i) + 0.15, stations100Hz{i}, ...
          'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b');
end


% Format plot
title('Station availability - RF analysis ');
set(gcf, 'Color', 'w');  
set(gca, 'Box', 'off', 'XColor', 'none', 'YColor', 'none');
grid on

legend(h1, 'Broadband Stations with 100 Hz channels - From year 1996-current / 5+ years duration', 'Location', 'best');

hold off;
%_________________________________________________________________


% ✅ Define file paths
inputFile40Hz = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_40Hz.txt';
inputFile100Hz = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_100Hz.txt';

outputFile40Hz_CSV = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_40Hz_Table.csv';
outputFile40Hz_TXT = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_40Hz_Table.txt';

outputFile100Hz_CSV = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_100Hz_Table.csv';
outputFile100Hz_TXT = '/Users/anuradhamahanama/Postdoctoral_CERI/CEUS_LITHO/Data_Prep_RF/Channel_5YearsOrMore_100Hz_Table.txt';

% ✅ Process and save 40Hz data
disp('📌 Processing 40Hz Data:');
 process_and_save(inputFile40Hz, outputFile40Hz_CSV, outputFile40Hz_TXT);

% ✅ Process and save 100Hz data
disp('📌 Processing 100Hz Data:');
 process_and_save(inputFile100Hz, outputFile100Hz_CSV, outputFile100Hz_TXT);

% --------------------------------------------------------------------------------------------------
% ✅ Define the function **AFTER** the main script to avoid MATLAB function errors
% --------------------------------------------------------------------------------------------------
function process_and_save(inputFile, outputCSV, outputTXT)
    % Read the channel file
    channelData = readcell(inputFile, 'Delimiter', '|');

    % Extract relevant columns
    network = string(channelData(:,1));      % Network
    station = string(channelData(:,2));      % Station
    location = string(channelData(:,3));     % Location (e.g., "00", "10")
    channel = string(channelData(:,4));      % Channel
    latitude = str2double(channelData(:,5)); % Convert to numeric
    longitude = str2double(channelData(:,6)); % Convert to numeric
    start_time = string(channelData(:,16));  % Start Time
    end_time = string(channelData(:,17));    % End Time

    % ✅ Fix Location Code Issue ("00" being turned into "0")
    location = replace(location, " ", "");  % Remove unnecessary spaces
    location(ismissing(location) | strlength(strtrim(location)) == 0) = "--";

    % ✅ Convert Start and End Time to datetime format
    start_time_dt = datetime(start_time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');
    end_time_dt = datetime(end_time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');

    % ✅ Calculate duration in years
    duration_years = years(end_time_dt - start_time_dt);
    duration_str = string(round(duration_years, 2)); % Round to 2 decimal places

    % ✅ Create a unique key for grouping (Network|Station)
    uniqueKeys = strcat(network, '|', station);
    [uniqueStations, ~, groupIdx] = unique(uniqueKeys);

    % ✅ Initialize results storage
    numStations = length(uniqueStations);
    tableData = cell(numStations, 10);  % Table will store results

    % ✅ Loop through unique stations
    for i = 1:numStations
        % Find all rows matching the current station
        idx = (groupIdx == i);
        
        % ✅ Extract and merge unique values as strings
        network_i = unique(network(idx));
        station_i = unique(station(idx));
        location_i = unique(location(idx));  % Merge multiple locations
        channel_i = unique(channel(idx));    % Merge multiple channels

        % ✅ Fix NaN issue for Latitude & Longitude using valid values
        valid_latitudes = latitude(idx);
        valid_longitudes = longitude(idx);

        % Remove NaN values and take mean of valid ones
        valid_latitudes(isnan(valid_latitudes)) = [];
        valid_longitudes(isnan(valid_longitudes)) = [];

        % **Ensure latitude and longitude are valid**
        if ~isempty(valid_latitudes)
            latitude_i = mean(valid_latitudes);
        else
            latitude_i = NaN;
        end

        if ~isempty(valid_longitudes)
            longitude_i = mean(valid_longitudes);
        else
            longitude_i = NaN;
        end

        % ✅ Debug Output to Confirm Latitude/Longitude Correctness
        fprintf('DEBUG: Station %s - Latitude: %.4f, Longitude: %.4f\n', station_i, latitude_i, longitude_i);

        % ✅ Fix issue where "00" turns into "0" by preserving original format
        location_str = strjoin(location_i, ', ');  % Keep text format
        channel_str = strjoin(channel_i, ', ');    % Keep text format

        start_time_i = min(start_time_dt(idx)); % Earliest start time
        end_time_i = max(end_time_dt(idx));     % Latest end time
        duration_i = round(years(end_time_i - start_time_i), 2); % Duration in years

        % ✅ Store in table format with explicit numeric conversion
        tableData{i,1} = i; % Row number
        tableData{i,2} = network_i(1);
        tableData{i,3} = station_i(1);
        tableData{i,4} = location_str;
        tableData{i,5} = channel_str;
        tableData{i,6} = double(latitude_i); % Force numeric conversion
        tableData{i,7} = double(longitude_i); % Force numeric conversion
        tableData{i,8} = datestr(start_time_i, 'yyyy-mm-dd HH:MM:SS'); % Start Time
        tableData{i,9} = datestr(end_time_i, 'yyyy-mm-dd HH:MM:SS');   % End Time
        tableData{i,10} = duration_i; % Duration in Years
    end

    % ✅ Convert to table format
    T = cell2table(tableData, 'VariableNames', ...
        {'#', 'Network', 'Station', 'Location(s)', 'Channel(s)', ...
        'Latitude', 'Longitude', 'Start Time', 'End Time', 'Duration (Years)'});

    % ✅ Print the table in the command window
    disp(T);

    % ✅ Save table as CSV
%     writetable(T, outputCSV);
    fprintf('✅ Saved table to CSV: %s\n', outputCSV);

    % ✅ Save table as TXT
%     writetable(T, outputTXT, 'Delimiter', 'tab');
    fprintf('✅ Saved table to TXT: %s\n', outputTXT);
end

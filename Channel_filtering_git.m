% Clear workspace
clear; clc; close all;

% Define the filenames (Change "FOLDER_PATH" to your own path where all the
% necessary files are stored )
ChannelFile = '/FOLDER_PATH/Channel.txt'; % Station info
outputFile = '/FOLDER_PATH/Channel_WithDuration.txt';

% These are two frequencies (40 Hz and 100 Hz), we filtered out here. Change it
% according to your need.

outputFile40 = '/FOLDER_PATH/40Channel.txt'; % 40 Hz output
outputFile100 = '/FOLDER_PATH/100Channel.txt'; % 100 Hz output
%% **READ Channel DATA**
channelData = readmatrix(ChannelFile, 'Delimiter', '|', 'NumHeaderLines', 1, 'OutputType', 'string');

% Extract relevant station parameters
stationStruct.Network          = channelData(:, 1);
stationStruct.Station          = channelData(:, 2);
stationStruct.Location         = channelData(:, 3);
stationStruct.Channel          = channelData(:, 4);
stationStruct.Latitude         = str2double(channelData(:, 5));
stationStruct.Longitude        = str2double(channelData(:, 6));
stationStruct.Elevation        = str2double(channelData(:, 7));
stationStruct.Depth            = str2double(channelData(:, 8));
stationStruct.Azimuth          = str2double(channelData(:, 9));
stationStruct.Dip              = str2double(channelData(:, 10));
stationStruct.SensorDesc       = channelData(:, 11);
stationStruct.Scale            = str2double(channelData(:, 12));
stationStruct.ScaleFreq        = str2double(channelData(:, 13));
stationStruct.ScaleUnits       = channelData(:, 14);
stationStruct.SampleRate       = str2double(channelData(:, 15));
stationStruct.StartTime        = channelData(:, 16);
stationStruct.EndTime          = channelData(:, 17);

%___________________________________________________________
% Extract necessary columns
stations = channelData(:, 2);  % Station names
networks = channelData(:, 1);  % Network names
uniqueStationIDs = strcat(networks, '|', stations);  % Combine Network & Station to have the uniqueness
startTime = datetime(channelData(:, 16), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');
endTime = datetime(channelData(:, 17), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSS');

% Compute duration in days and convert to years
durationDays = days(endTime - startTime);
durationYears = durationDays / 365.25;

% Define categories (This can be extended as per your need)
categories = { ...
    'Less than 1 year', durationYears < 1; ...
    'More than 2 years', durationYears > 2; ...
    'More than 3 years', durationYears > 3; ...
    'More than 4 years', durationYears > 4; ...
    'More than 5 years', durationYears > 5; ...
};

% Display results
fprintf('Duration Category | Channels | Unique Stations\n');
fprintf('---------------------------------------------\n');

for i = 1:size(categories, 1)
    categoryName = categories{i, 1};
    categoryFilter = categories{i, 2};

    % Count channels in this category
    numChannels = sum(categoryFilter);

    % Find unique stations in this category
    uniqueStationsInCategory = unique(uniqueStationIDs(categoryFilter));
    numUniqueStations = length(uniqueStationsInCategory);

    % Print results
    fprintf('%-18s | %-8d | %d\n', categoryName, numChannels, numUniqueStations);
end

%___________________________________________________________
% Extract the sampling rates
sampleRates = str2double(channelData(:, 15));

% Get unique sampling rates and count occurrences
[uniqueSampleRates, ~, idx] = unique(sampleRates);
channelCounts = accumarray(idx, 1);

% Display results
fprintf('Sampling Rate (Hz) | Number of Channels\n');
fprintf('--------------------------------------\n');
for i = 1:length(uniqueSampleRates)
    fprintf('%15.2f | %d\n', uniqueSampleRates(i), channelCounts(i));
end

%___________________________________________________________
% Filter rows for 40 Hz and 100 Hz
filter40 = sampleRates == 40;
filter100 = sampleRates == 100;

data40Hz = channelData(filter40, :);
data100Hz = channelData(filter100, :);

% % **Write filtered data back to text files**
writematrix(data40Hz, outputFile40, 'Delimiter', '|');
writematrix(data100Hz, outputFile100, 'Delimiter', '|');

% Display completion message
fprintf('Saved %d channels with 40 Hz sampling rate to %s\n', sum(filter40), outputFile40);
fprintf('Saved %d channels with 100 Hz sampling rate to %s\n', sum(filter100), outputFile100);

% Get all unique sampling rates dynamically (without 500 Hz)
uniqueSampleRates = unique(sampleRates);
numRates = length(uniqueSampleRates);

% Define interval-based duration categories
categories = { ...
    'Less than 1 year', durationYears < 1; ...
    '1 - 2 years', durationYears >= 1 & durationYears < 2; ...
    '2 - 3 years', durationYears >= 2 & durationYears < 3; ...
    '3 - 4 years', durationYears >= 3 & durationYears < 4; ...
    '4 - 5 years', durationYears >= 4 & durationYears < 5; ...
    '5 or more years', durationYears >= 5; ...
};

% Display results header
fprintf('Duration Category   | Channels | ');
for r = 1:numRates
    fprintf('%-5dHz | ', uniqueSampleRates(r));
end
fprintf('Unique Stations\n');
fprintf('-----------------------------------------------------------------------------\n');

for i = 1:size(categories, 1)
    categoryName = categories{i, 1};
    categoryFilter = categories{i, 2};

    % Count total channels in this category
    numChannels = sum(categoryFilter);

    % Count number of unique stations in this category
    uniqueStationsInCategory = unique(uniqueStationIDs(categoryFilter));
    numUniqueStations = length(uniqueStationsInCategory);

    % Count number of channels for each sampling rate
    rateCounts = zeros(1, numRates);
    for r = 1:numRates
        rateCounts(r) = sum(categoryFilter & (sampleRates == uniqueSampleRates(r)));
    end

    % Print results in the new format
    fprintf('%-18s | %-8d | ', categoryName, numChannels);
    fprintf('%-5d | ', rateCounts);
    fprintf('%-8d\n', numUniqueStations);
end

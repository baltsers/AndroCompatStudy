% Read data from a TSV file
data = readmatrix('iir_malware_overall_output.tsv', 'FileType', 'text', 'Delimiter', '\t');

% Assign columns to variables
failure_rate = data(:,1);
minsdk = data(:,2);
api = data(:,3);
year = data(:,4);
api_year = data(:,5);
api_minus_year = data(:,6);
api_minus_minsdk = data(:,7);

% Prepare variables for plotting
x = api_minus_minsdk;
y = api_minus_year;
z = failure_rate;

% Draw 3D scatter diagram with input data
figure;
% Uncomment the below lines for a more complex plot setup
% set(gcf,'color',[.87 .87 .87]);
% XL = get(gca, 'XLim');
% YL = get(gca, 'YLim');
% patch([XL(1), XL(2), XL(2), XL(1)], [YL(1), YL(1), YL(2), YL(2)], [0 0 0 0 0], 'FaceColor', [0 1 0]);
scatter(x, y, 30, z, '_', 'LineWidth', 5);
ylim([-10 10]);
xlim([-11 30]);
xticks([-10, -5, 0, 5, 10, 15, 20, 25, 30]);  % Set XTick as specified
clim([0 1]);    % Set color axis scaling from 0 to 1
colorbar('Ticks', 0:0.1:1); % Set colorbar ticks from 0 to 1 with a step of 0.1

% zoom(2);
colorbar;

xlabel('API lapse', 'FontSize', 12, 'Color', 'red');
ylabel('App lapse', 'FontSize', 12, 'Color', 'blue');

% Optional settings for a more polished plot
% title('Failed execution percentage distribution among different API levels');
% zlabel('RIR', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'black');


fig = gcf;
fig.PaperUnits = 'inches';  % Set units to inches for PaperSize
fig.PaperSize = [8.5 11];
fig.PaperPosition = [1.8611, 3.7639, 4.7778, 3.4722]; % Set the paper position
fig.InnerPosition = [1291,402,344,250]
fig.OuterPosition = [1291,402,344,329]

fig.InvertHardcopy = 'off';
% saveas(gcf, 'GrayBackground.pdf')

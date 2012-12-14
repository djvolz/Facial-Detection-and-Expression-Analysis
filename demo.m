
% ------------- Run the mouth detector function here ------------- 
%
%
% Inputs to mouth_detector: mouth_detector(input) takes in an input .jpg file
%
% Outputs of mouth_detector: [numMouthPoints,lineCurvature]
%
% numMouthPoints is the number of detected corner points on each mouth expression
% lineCurvature is the concavity of the date points which is either positive or negative
%
% ----------------------------------------------------------------
%  
%   Authors: Justin DeVito, Amanda Meurer, Daniel Volz
%   
%   Rice University, ELEC 301, 2014
%
% ----------------------------------------------------------------



% ----------------------Inputs for demo---------------------------

numOfFiles = 4; % Number of files to be compared

name = 'Danny';

% ----------------------------------------------------------------


thresh = 10; % Minimum number of mouth corner detection points required to be a valid conclusion
threshMin = 10;

M = zeros(numOfFiles,2); % Initialize comparison matrix

for j = 1:numOfFiles
    % Smile Picture
    input = [num2str(j) '_' name '.jpg'];
    [M(j,1),M(j,2)] = mouth_detector(input);
    %close all   
   
end

% M is displayed in the command window for informational purposes
disp('The Matrix of numMouthPoints and lineCurvature')
disp(M)

% Cannot compare if only one file is analyzed
if numOfFiles > 1
    
    % Matrix value with the greatest number of mouth points
    maxpts = max(M(:,1));
    
   % Eliminate values below threshold from matrix
    minIndex = find(M(:,1) < threshMin);
    if ~isempty(minIndex)
        M(minIndex',1)=0;
        M(minIndex',2)=0;
    end
    
    % Mouth points of image must meet minimum threshold criteria
    if maxpts > thresh
        % Check to see if lineCurvature is positive
        if max(M(:,2)) > 0
            maxCurvIdx = find(M(:,2) == max(M(:,2)));
            disp(['The Best Smile from ' name ' is Number ' num2str(maxCurvIdx)])
            resultMessage = ['The Best Smile from ' name ' is Number ' num2str(maxCurvIdx)];
           
        else
            disp('No smiles detected.')
            resultMessage = 'No smiles detected.';
        end
    % If threshold is not met then results are inconclusive
    else
        disp('Inconclusive')
        resultMessage = 'Inconclusive';
    end
else
    resultMessage = 'Input more than one file for comparison.';
end


% Results Message
figure
set(gcf,'Color', 'white');
text(0,0.5,resultMessage,'fontsize',20);
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');



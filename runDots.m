function data = runDots
%% Experiment initializer
% SAFER MOUSE ZONE
%
%
%
%
%
%
%
%
% get pt info, load experiment param, launch experiment, record results
clear; close; commandwindow;
startTime = datetime('now');

%% Experiment Type & Version
data.expType = 'gradShift';

%% Get Participant Info
data.ptInfo =  getPtInfo(data);
data.expVers = data.ptInfo{end}; % same / soa

%% Get Task Parameters
data.param = expParam(data,'taskParam');
data.param.ptInfo = data.ptInfo;
%get keys & confirm
data.param.keys.left = data.param.ptInfo{7};
data.param.keys.right =  data.param.ptInfo{8};


%% Launch gsDOTS
data.results = gsDots(data.param);

%save time
data.time.startTime  = startTime;
data.time.endTime    = datetime('now');
data.time.expDur     = data.time.endTime - data.time.startTime;


%% Save
if ~exist('results', 'dir'); mkdir results; end
save(fullfile('results', [datestr(now,'yyyy-mm-dd'), '_dots', num2str(data.ptInfo{1}),'.mat']), 'data');


%% Close and return to main folder
Screen('CloseAll');
rng('default');
ShowCursor;
fclose('all');
Screen('Preference', 'Verbosity', 3);


end



%% ======== GET PARTICIPANT INFO
function ptInfo = getPtInfo(data)

dlgInfo = expParam(data,'ptInfo');

ptInfo = inputdlg(dlgInfo.prompt,'Participant Information', 1, dlgInfo.default, dlgInfo.options);
assert(~isempty(ptInfo), 'experiment cancelled by user')


%% convert inputs to num if necessary (e.g., age)
if isfield(dlgInfo, 'num')
    
    for d = 1:length(ptInfo)
        
        if dlgInfo.num(d)
            ptInfo{d} = str2double(ptInfo{d});
        end
        
    end
    
end

%% Check to see if overwriting a participant

if exist(fullfile('results', [datestr(now,'yyyy-mm-dd'), '_dots', num2str(ptInfo{1}),'.mat']), 'file') == 2
    
    button = questdlg('Do you want to overwrite this participant?');
    
    switch button
        case 'No'
            getPtInfo(data);
        case 'Cancel'
            error('experiment cancelled by user');
    end
    
end


end





%% ======== GET EXPERIMENTAL PARAMETERS
function out = expParam(data, paramType)

switch data.expType
    
    case 'gradShift'
        
        switch paramType
            
            case 'ptInfo'
                
                %% PT info
                out.prompt = {...
                    'Participant Number',...
                    'Age',...
                    'Sex',...
                    'Monitor Width (cm)',...
                    'Viewing Distance (cm)',...
                    'color - {teuf, isolum}',...
                    'Left Key',...
                    'Right Key',...
                    'Version - {same, soa}'};
                
                out.default                 = {'99', '50', 'F', '38', '60', 'teuf', 'f', 'j', 'same'};
                out.options.Resize          = 'on';
                out.options.WindowStyle     = 'normal';
                out.num                     = [1 1 0 1 1 0 0 0 0];
                
            case 'taskParam'
                
                
                switch data.expVers
                    
                    case {'same'}
                        
                        
                        %% SAME: both dimensions onset at the same time, random conflict over trials
                        
                        
                        %% version
                        out.expVers = data.expVers;
                        
                        %% Trials & Blocks
                        out.motionTr     = 50;   %motion training trials
                        out.motionBl     = 1;   %motion training blocks
                        
                        out.colorTr     = 50;   %color training trials
                        out.colorBl     = 1;    %color training blocks
                        
                        out.randTr     = 90;    %random trials
                        out.randBl     = 7;     %random blocks [90-30-90-30-90-30-90]; blocks 2:2:end are motion
                        
                        out.ordTr     = 0;      %ordered trials
                        out.ordBl     = 0;      %ordered blocks
                        
                        out.motionMainTr = 30;  %motion blocks
                        
                        
                        %% Task settings
                        %Currently: space conflict levels between
                        %[-cohRange(2) and cohRange(2)]
                        
                        % ===== shift aperture
                        out.shiftAp = 0; %move the apature to match the dot motion
                        out.sizeShiftAp = 0; %how much to move apature? (px)
                        
                        % ===== change offset
                        out.offset = 0; %is there an SOA?
                        out.gradAtt.T0color     = -999; % when color
                        out.gradAtt.T0motion    = -999; % when motion
                        out.onsetJitter = [0, 0];
                        out.gradAtt.preT0mCoh   = 0; % pre-offset motion coh
                        
                        % ===== task randomization
                        out.rand = 1; %randomize the order of conflict levels?
                        out.confLevels = 11; % number of levels of conflict between [high coherence congreunt:low coherence congreunt:low coherence incongreunt: high coherence incongreunt]
                        out.driftConfLevels = 11; %levels for testing drift conf
                        
                        out.cohRange = [0 950]; %range of motion coherence
                        out.ITI = [0.5, 1]; % ITI
                        out.feedbackDur = 1;
                        out.errFeedDur = 2;
                        out.dotSettings.InterogationFixedTimeLength = 5;  % Length of time of dots displayed
                        
                        
                        % ===== Show Block Type
                        out.showBlockType = 0;
                        
                        % ===== Show fixation
                        out.showAttendCues = 1;
                        out.cueSize = 50;
                        out.startCue = 0.300;
                        
                        
                        
                        %% ==== dot colors
                        switch data.ptInfo{6}
                            
                            case 'teuf'
                                out.dotSettings.dotColor1 = [187   165   222];
                                out.dotSettings.dotColor2 = [150   180   198];
                                out.dotSettings.dotColor3 = [192   169   168];
                                out.dotSettings.dotColor4 = [157   184   130];
                                
                                out.dotSettings.colNames = {'Purple','Blue','Beige','Green'};
                                
                            case 'isolum'
                                
                                out.dotSettings.dotColor1 =[ 239   143   143];
                                out.dotSettings.dotColor2 = [ 191   239   143];
                                out.dotSettings.dotColor3 = [ 143   239   239];
                                out.dotSettings.dotColor4 = [ 191   143   239];
                                
                                out.dotSettings.colNames = {'Red','Yellow','Blue','Purple'};
                                
                        end
                        
                        
                        
                        
                        %% attended dimensions
                        out.dotInfo.curColor = 1; %default to.. blue? (but will be random if not used)
                        out.dotInfo.dir = 0; %default to left (but will be random if not used)
                        out.dotInfo.curSize = 2; %always big dots
                        
                        %% set coherence
                        out.dotInfo.colorCoh = 1000;
                        out.dotInfo.coh = 1000;
                        out.dotInfo.sizeCoh = 1000;
                        
                        %% OUTCOMES
                        out.currOuts.locHaz      = 0.8; % hazard rate for stable mean
                        out.currOuts.transMin    = 8;   % min trials between stable means
                        out.currOuts.transRange  = 12;   % range of trials between stable means
                        out.currOuts.locRange    = [-180 180];  % range of transitions (+/- current mean)
                        
                        %% variances
                        out.currOuts.varHaz      = 0.4;  % variance hazard rate
                        out.currOuts.varMin      = 1;    % min variance
                        out.currOuts.varRange    = 7;   % range of variances
                        
                        
                        
                        
                        %% dotSettings
                        out.CTS.MaxRT = 3;
                        out.dotSettings.dotApFrameWidth = NaN;                                       % Helps deal w/ edge effects - set to nan to exclude dot frame
                        out.dotSettings.dotApFrameScale = 1.05;                                      % Amount to scale aperture rect (assuming square aperture!)
                        out.dotSettings.dotsPerSqDeg = 33.4*2;                                       % If no dots per square degree is inputed, sets the dots per square degree
                        out.dotSettings.dotApertSize = 150;%75;                                      % Degrees visual angle (default = 5)
                        %                         out.dotSettings.dotColor1 = [5 137 255];                                   % Color of dots 1
                        %                         out.dotSettings.dotColor2 = [255 65 2];                                    % Color of dots 2
                        
                        
                        
                        out.dotCols = [out.dotSettings.dotColor1;...
                            out.dotSettings.dotColor2;...
                            out.dotSettings.dotColor3;...
                            out.dotSettings.dotColor4;];
                        
                        
                        out.dotSettings.dotSize = 4;                                                 % Size of dots, default = 2
                        out.dotSettings.dotSpeed = 150;                                              % Speed of dots default = 50
                        out.dotSettings.dirSet = [90,270];                                           % vertical vectors, dots direction (degrees) for each dot patch
                        out.dotSettings.ColorSet= [0 1];                                             % Color order
                        out.dotSettings.coh(1,1) = 0.3*1000;                                         % Starting color coherence
                        out.dotSettings.coh(2,1) = 0.3*1000;                                         % Starting motion coherence
                        
                        
                        
                        
                    case {'soa'}
                        
                        
                        %% SOA: dimenions onset at different times, with predictable conflict over time
                        
                        
                        
                        %% version
                        out.expVers = data.expVers;
                        
                        
                        %% Trials & Blocks
                        out.motionTr     = 50;   %motion training trials
                        out.motionBl     = 1;   %motion training blocks
                        
                        out.colorTr     = 50;    %color training trials
                        out.colorBl     = 1;    %color training blocks
                        
                        out.randTr     = 0;     %random trials
                        out.randBl     = 0;     %random blocks
                        
                        out.ordTr     = 90;     %ordered trials
                        out.ordBl     = 7;      %ordered blocks [90-30-90-30-90-30-90]; blocks 2:2:end are motion
                        
                        out.motionMainTr = 30;      %motion trials
                        
                        
                        %% Task settings
                        
                        % ===== shift aperture
                        out.shiftAp = 0; %move the apature to match the dot motion
                        out.sizeShiftAp = 0; %how much to move apature? (px)
                        
                        % ===== change offset
                        out.offset = 1; %is there an offset
                        out.gradAtt.T0color     = .250; % when color
                        out.gradAtt.T0motion    = .250; % when motion
                        out.gradAtt.preT0mCoh   = 0; % pre-offset motion coh
                        out.onsetJitter = [-.025, .025];
                        
                        % ===== task parameters
                        out.rand = 1; %randomize the order of conflict levels?
                        
                        out.confLevels = 11; % number of levels of conflict between [high coherence congreunt:low coherence congreunt:low coherence incongreunt: high coherence incongreunt]
                        out.driftConfLevels = 11; %levels for testing drift conf
                        
                        %Currently: space conflict levels between
                        %[-cohRange(2) and cohRange(2)]
                        out.cohRange = [0, 950]; %range of motion coherence
                        out.ITI = [0.5,  1]; % ITI
                        out.feedbackDur = 1;
                        out.errFeedDur = 2;
                        out.dotSettings.InterogationFixedTimeLength = 5;  % max length of time of dots displayed
                        
                        % ===== Show Block Type
                        out.showBlockType = 0;
                        
                        % ===== Show fixation
                        out.showAttendCues = 1;
                        out.cueSize = 50;
                        out.startCue = 0.300;
                        
                        
                        
                        %% ==== dot colors
                        switch data.ptInfo{6}
                            
                            case 'teuf'
                                out.dotSettings.dotColor1 = [187   165   222];
                                out.dotSettings.dotColor2 = [150   180   198];
                                out.dotSettings.dotColor3 = [192   169   168];
                                out.dotSettings.dotColor4 = [157   184   130];
                                
                                out.dotSettings.colNames = {'Purple','Blue','Beige','Green'};
                                
                            case 'isolum'
                                
                                out.dotSettings.dotColor1 =[ 239   143   143];
                                out.dotSettings.dotColor2 = [ 191   239   143];
                                out.dotSettings.dotColor3 = [ 143   239   239];
                                out.dotSettings.dotColor4 = [ 191   143   239];
                                
                                out.dotSettings.colNames = {'Red','Yellow','Blue','Purple'};
                                
                        end
                        
                        
                        %% attended dimensions
                        out.dotInfo.curColor = 1; %default to.. blue? (but will be random if not used)
                        out.dotInfo.dir = 0; %default to left (but will be random if not used)
                        out.dotInfo.curSize = 2; %always big dots
                        
                        %% set coherence
                        out.dotInfo.colorCoh = 1000;
                        out.dotInfo.coh = 1000;
                        out.dotInfo.sizeCoh = 1000;
                        
                        %% OUTCOMES
                        out.currOuts.locHaz      = 0.8; % hazard rate for stable mean
                        out.currOuts.transMin    = 8;   % min trials between stable means
                        out.currOuts.transRange  = 12;   % range of trials between stable means
                        out.currOuts.locRange    = [-180 180];  % range of transitions (+/- current mean)
                        
                        %% variances
                        out.currOuts.varHaz      = 0.4;  % variance hazard rate
                        out.currOuts.varMin      = 1;    % min variance
                        out.currOuts.varRange    = 7;   % range of variances
                        
                        
                        %% dotSettings
                        out.CTS.MaxRT = 3;
                        out.dotSettings.dotApFrameWidth = NaN;                                       % Helps deal w/ edge effects - set to nan to exclude dot frame
                        out.dotSettings.dotApFrameScale = 1.05;                                      % Amount to scale aperture rect (assuming square aperture!)
                        out.dotSettings.dotsPerSqDeg = 33.4*2;                                       % If no dots per square degree is inputed, sets the dots per square degree
                        out.dotSettings.dotApertSize = 150;%75;                                      % Degrees visual angle (default = 5)
                        %                         out.dotSettings.dotColor1 = [5 137 255];                                   % Color of dots 1
                        %                         out.dotSettings.dotColor2 = [255 65 2];                                    % Color of dots 2
                        
                        
                        
                        out.dotCols = [out.dotSettings.dotColor1;...
                            out.dotSettings.dotColor2;...
                            out.dotSettings.dotColor3;...
                            out.dotSettings.dotColor4;];
                        
                        out.dotSettings.dotSize = 4;                                                 % Size of dots, default = 2
                        out.dotSettings.dotSpeed = 150;                                              % Speed of dots default = 50
                        out.dotSettings.dirSet = [90,270];                                           % vertical vectors, dots direction (degrees) for each dot patch
                        out.dotSettings.ColorSet= [0 1];                                             % Color order
                        out.dotSettings.coh(1,1) = 0.3*1000;                                         % Starting color coherence
                        out.dotSettings.coh(2,1) = 0.3*1000;                                         % Starting motion coherence
                        
                        
                        
                        
                    otherwise
                        
                        error('Incorrect experiment code');
                        
                        
                end
                
        end
        
        
end

end





%%  ========== gsDots


function out = gsDots(param)
%% gsDots
% participants perform a simon-like task, dot colors which are are mapped
% to each had, with dot motion that is congruent or incongruent to their
% color response, with the coherence of the dot motion modulating the
% ammount of conflict. The amount of conflict changes over time, with a
% history of conflict levels that varies over time with predicable
% trajectory.


debug = 0;

if debug
    PsychDebugWindowConfiguration([],[.5]);
else
    HideCursor;
end



%Clear Matlab window:
clc;

% check for Opengl compatibility, abort otherwise:
AssertOpenGL;
KbName('UnifyKeyNames');
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebuglevel',0);
Screen('Preference','SuppressAllWarnings',1);
commandwindow;

try
    
    % Get screenNumber of stimulation display. We choose the display with
    % the maximum index, which is usually the right one, e.g., the external
    % display on a Laptop:
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    %% monitor width
    
    param.monWidth = param.ptInfo{4};
    param.viewDist = param.ptInfo{5};
    
    
    
    
    
    
    screenInfo = openExperiment(param.monWidth,param.viewDist,0);
    
    screenInfo.showAttendCues = param.showAttendCues;  % Show letter cue throughout dot display
    screenInfo.cueTextSize = param.cueSize;
    
    
    
    %% call task
    
    out = callSimonTask(screenInfo, param);
    
    out.screenInfo = screenInfo;
    
    
    
catch
    % catch error: This is executed in case something goes wrong in the
    % 'try' part due to programming error etc.:
    
    % Do same cleanup as at the end of a regular session...
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
end % try ... catch %


end












function out = callSimonTask(screenInfo, param)

%% Get dot info
[dotInfo, param] = getDotInfo(param);

%% CALL DIFFERENT TASKS


%% ======= TRAINING SECTION
trainCBMx = [1,2; 2,1];
trainCB = (mod(param.ptInfo{1}-1, 8) >= 4)+1;

% if mod(param.ptInfo{1}, 8) > 4

for bb = 1:2
    
    if trainCBMx(trainCB, bb) == 1
        
        if param.motionTr == 0; continue; end %skip if no motion trials
        
        %% motion only
        kind = 'motion';
        
        param.nTr = param.motionTr;
        param.nBl = param.motionBl;
        param.rand = 1;
        param.feedback = 1;
        param.shiftAp = 1;
        
        param.currOuts.nTr =  param.motionTr;
        param.currOuts.nBl =  param.motionBl;
        
        [out.motion.dotInfo, out.motion.param, out.motion.session] = showSimon(screenInfo, param, dotInfo, kind);
        
        
        if any(out.motion.session.behav.resp(:) == -999) % return if abort
            return;
        end
        
        
    else
        
        %% color only
        kind = 'color';
        
        param.nTr = param.colorTr;
        param.nBl = param.colorBl;
        param.rand = 1;
        param.feedback = 1;
        param.shiftAp = 0;
        
        param.currOuts.nTr =  param.colorTr;
        param.currOuts.nBl =  param.colorBl;
        
        
        [out.color.dotInfo, out.color.param, out.color.session] = showSimon(screenInfo, param, dotInfo, kind);
        
        if any(out.color.session.behav.resp(:) == -999) % return if abort
            return;
        end
        
        
    end
    
end


%% MAIN SECTION
mainCBMx = [1,2; 2,1];
mainCB = (mod(param.ptInfo{1}-1, 4) >= 2)+1;

for bb = 1:2
    
    if param.randTr > 0 && mainCBMx(mainCB, bb) == 1
        
        %% random
        kind = 'random';
        
        param.nTr = param.randTr;
        param.nBl = param.randBl;
        param.rand = 1;
        param.feedback = 0;
        param.shiftAp = 1;
        
        param.currOuts.nTr =  param.randTr;
        param.currOuts.nBl =  param.randBl;
        
        [out.rand.dotInfo, out.rand.param, out.rand.session] = showSimon(screenInfo, param, dotInfo, kind);
        
        if any(out.rand.session.behav.resp(:) == -999) % return if abort
            return;
        end
        
        
    elseif param.ordTr > 0  && mainCBMx(mainCB, bb) == 2
        
        %% ordered
        kind = 'ordered';
        
        param.nTr = param.ordTr;
        param.nBl = param.ordBl;
        param.confLevels = param.driftConfLevels;
        param.rand = 0;
        param.feedback = 0;
        param.shiftAp = 1;
        
        param.currOuts.nTr =  param.ordTr;
        param.currOuts.nBl =  param.ordBl;
        
        [out.ord.dotInfo, out.ord.param, out.ord.session] = showSimon(screenInfo, param, dotInfo, kind);
        
        if any(out.ord.session.behav.resp(:) == -999) % return if abort
            return;
        end
        
    end
    
end


end



%% DOT INFO
function [dotInfo, param] = getDotInfo(varargin)

if(~isempty(varargin))
    param = varargin{1};
end

dotInfo = createMinDotInfo(1);

% exp variables
%% dotInfo
dotInfo.keyLeft = KbName('z');                                         % Left Key
dotInfo.keyUp = KbName('s');                                          % Up Key
dotInfo.keyRight = KbName('c');                                          % Right Key
dotInfo.keyDown = KbName('h');                                         % Down

if isfield(param, 'keys')
    dotInfo.keyLeft = KbName(param.keys.left);                                         % Left Key
    dotInfo.keyRight = KbName(param.keys.right);                                          % Right Key
end

dotInfo.maxDotTime = param.CTS.MaxRT;
dotInfo.apFrameWidth = param.dotSettings.dotApFrameWidth;
dotInfo.apFrameScale = param.dotSettings.dotApFrameScale;
dotInfo.dotsPerSqDeg = param.dotSettings.dotsPerSqDeg;
dotInfo.apXYD(3) = param.dotSettings.dotApertSize;
dotInfo.dotColor = param.dotSettings.dotColor1;
dotInfo.dotColor2 = param.dotSettings.dotColor2;
dotInfo.dotSize = param.dotSettings.dotSize;
dotInfo.speed = param.dotSettings.dotSpeed;
dotInfo.allowContinuedKeyCheck = 1; % get response during stim
% dotInfo.colorDelay = 1; % Will there be a color delay? (0: no, 1:yes)
% dotInfo.colorOnset = .5; % how many secs to delay color?


%% offset
dotInfo.offset = param.offset;
dotInfo.gradAtt.T0color = param.gradAtt.T0color;
dotInfo.gradAtt.T0motion = param.gradAtt.T0motion;
dotInfo.gradAtt.preT0mCoh = param.gradAtt.preT0mCoh;


%% attend cue
dotInfo.curAttendCue = '+';


end


function dotInfo = createMinDotInfo(inputtype,numFields)
% dotInfo = createDotInfo(inputtype)
% creates the default dotInfo structure. inputtype is 1 for using keyboard,
% 2 for using touchscreen/mouse
% only includes fields necessary to run dots themselves, to run one of the
% paradigms see createDotInfo
% saves the structure in the file dotInfoMatrix or returns it

% created June 2006 MKMK

if ~exist('numFields','var')
    numFields = 1;
end

%mfilename

if nargin < 1
    inputtype = 1; % use keyboard
    %     inputtype = 2; % use touchscreen
end

if numFields==1
    % to have more than one set of dots, all of these must have information for
    % more than one set of dots: aperture, speed, coh, direction, maxDotTime
    dotInfo.numDotField = 1;
    dotInfo.apXYD = [0 0 100];
    % dotInfo.apXYD = [0 50 50];
    %dotInfo.apXYD = [0 0 50];
    dotInfo.speed = 50;
    dotInfo.coh = 512;
    dotInfo.dir = 180;
    dotInfo.maxDotTime = 10;
    % dotInfo.maxDotTime = 2;
    dotInfo.colorCoh = nan; % 512
    dotInfo.curColor = 0;
else
    dotInfo.numDotField = 2;
    dotInfo.apXYD = [-50 0 50; 50 0 50];
    %dotInfo.apXYD = [150 0 50; -150 0 50];
    dotInfo.speed = [50 50];
    dotInfo.coh = [512 512];
    dotInfo.dir = [0 90];
    dotInfo.maxDotTime = [3 3];
    
    dotInfo.colorCoh = [nan nan]; % [512 512]
    dotInfo.curColor = [0 0];
end
dotInfo.dotColor = [255 255 255]; % white dots default
dotInfo.dotColor2 = [255 0 0]; %
dotInfo.pctColor1 = 0.8; %


dotInfo.curAttendCue = ''; % Letter appears at center of dot array

dotInfo.showAfterRT = 0; % continue stim display till max RT regardless of RT

%dotInfo.trialtype = [1 1];
% [1 fixed duration 2 reaction time,  1 hold on 2 hold off] hold on means
% subject has to hold fixation during task.
dotInfo.trialtype = [2 2];


% dot size in pixels
dotInfo.dotSize = 3;
% dotInfo.dotSize = 2;

% trialInfo.auto
% column 1: 1 to set manually, 2 to use fixation as center point, 3 to use aperture
% as center
% column 2: 1 to set coherence manually, 2 random, 3 correction mode
% column 3: 1 to set direction manually, 2 random
dotInfo.auto = [3 2 2];

%%%%%%% BELOW HERE IS STUFF THAT SHOULD GENERALLY NOT BE CHANGED!

dotInfo.maxDotsPerFrame = 150;   % by trial and error.  Depends on graphics card
dotInfo.dotsPerSqDeg = 16.7;

% Use test_dots7_noRex to find out when we miss frames.
% The dots routine tries to maintain a constant dot density, regardless of
% aperture size.  However, it respects MaxDotsPerFrame as an upper bound.
% The value of 53 was established for a 7100 with native graphics card.

% possible keys active during trial
dotInfo.keyEscape = KbName('escape');
dotInfo.keySpace = KbName('space');
dotInfo.keyReturn = KbName('return');
if inputtype == 1
    dotInfo.keyLeft = KbName('leftarrow');
    dotInfo.keyRight = KbName('rightarrow');
end

if inputtype == 1
    dotInfo.keyLeft = KbName('leftarrow');
    dotInfo.keyRight = KbName('rightarrow');
else
    mouse_left = 1;
    mouse_right = 2;
    dotInfo.mouse = [mouse_left, mouse_right];
end

if nargout < 1
    save dotInfoMatrix dotInfo
end
end









function screenInfo = openExperiment(monWidth, viewDist, curScreen)
% screenInfo = openExperiment(monWidth, viewDist, curScreen)
% Arguments:
%	monWidth ... viewing width of monitor (cm)
%	viewDist     ... distance from the center of the subject's eyes to
%	the monitor (cm)
%   curScreen         ... screen number for experiment
%                         default is 0.
% Sets the random number generator, opens the screen, gets the refresh
% rate, determines the center and ppd, and stops the update process
% Used by both my dot code and my touch code.
% MKMK July 2006

% mfilename
% 1. SEED RANDOM NUMBER GENERATOR
% screenInfo.rseed = rng('shuffle');
screenInfo.rseed = sum(100*clock);
rand('state',screenInfo.rseed);




% ---------------
% open the screen
% ---------------

% make sure we are using openGL
AssertOpenGL;

if nargin < 3
    curScreen = 0;
end

% added to make stuff behave itself in os x with multiple monitors
Screen('Preference', 'VisualDebugLevel',1);
Screen('Preference', 'SkipSyncTests', 1);

%%%%

% Set the background to the background value.
screenInfo.bckgnd = 0;
try
    [screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', curScreen, screenInfo.bckgnd,[],32, 2);
catch me2
    keyboard
end

screenInfo.dontclear = 0; % 1 gives incremental drawing (does not clear buffer after flip)

%get the refresh rate of the screen
% need to change this if using crt, would be nice to have an if
% statement...
%screenInfo.monRefresh = Screen(curWindow,'FrameRate');
spf =Screen('GetFlipInterval', screenInfo.curWindow);      % seconds per frame
screenInfo.monRefresh = 1/spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;

screenInfo.center = [screenInfo.screenRect(3) screenInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)

% determine pixels per degree
% (pix/screen) * ... (screen/rad) * ... rad/deg
screenInfo.ppd = pi * screenInfo.screenRect(3) / atan(monWidth/viewDist/2) / 360;    % pixels per degree

% if reward system is hooked up, rewardOn = 1, otherwise rewardOn = 0;
screenInfo.rewardOn = 0;
%screenInfo.rewardOn = 1;

% get reward system ready
screenInfo.daq=DaqDeviceIndex;


end












%% ========================== DO THE TASK! SET UP THE BLOCKS/TRIALS



function [dotInfo, param, data] = showSimon(screenInfo, param, dotInfo, kind)
%% [dotInfo params data] = showSimon(screenInfo, params, dotInfo)
% display dots, collect responses
% Harrison Ritz 2017 harrison.ritz@gmail.com

%% set-up
dotInfo.trialtype(1) = 1;                                           % Sets to Interrogation
wPtr = screenInfo.curWindow;

ScreenSize = screenInfo.screenRect;                       % Get screen size
Yres = ScreenSize(4);                                     % Gets the Y (vertical) resolution in pixels
Xres = ScreenSize(3);                                     % Gets the X (horizonal) resolution in pixels

white=[255 255 255];
grey = [150, 150, 150];

commandwindow;
data.startTime = fix(clock);

%% set size to be constant
dotInfo.curSize = 2;
dotInfo.sizeCoh = 1000;
dotInfo.curColor = 0; % set color to be constant, and change color of dotsetting

%% randomize colors
% shift so that similar colors are always oppposites across participants
% cols = cat(3, circshift(param.dotCols, param.ptInfo{1}, 1),...
%     circshift(param.dotCols, param.ptInfo{1}+2, [1, 0]));
% colorNames = circshift(param.dotSettings.colNames, [param.ptInfo{1} 0]);

% (yuck)

cols = cat(3, param.dotCols(mod((1:4) + param.ptInfo{1}, 4) + 1,:),...
    param.dotCols(mod((1:4) + param.ptInfo{1} + 2, 4) + 1, :));

colorNames = param.dotSettings.colNames(mod((1:4) + param.ptInfo{1}, 4) + 1);

% hack-y way to set trials for color blocks
nTrOrig = param.nTr;


%% aperture shift look-up
apLoc = [...
    param.sizeShiftAp,0,0; ...
    0,param.sizeShiftAp,90;...
    -param.sizeShiftAp,0,180;...
    0,-param.sizeShiftAp,270;...
    ];


%% onset lookup
onsetMx = [-999, -999; param.gradAtt.T0color, -999; -999, param.gradAtt.T0motion];
onsetCond = -1;

%% set up experiment version

dirs = [180 180 0 0; 0 0 180 180]; % motion directions
respList = [1 1 3 3]; % Map responses on to color/motion

KeyInfoColor = ['LEFT key: ' colorNames{1} '     RIGHT key: ' colorNames{3} '\n\n' ...
    'LEFT key: ' colorNames{2} '     RIGHT key: ' colorNames{4}];

KeyInfoMotion = ['LEFT key: LEFT motion     RIGHT key: RIGHT motion'];


%% save parameters
param.dirs = dirs;
param.respList = respList;
param.KeyInfoColor = KeyInfoColor;
param.KeyInfoMotion = KeyInfoMotion;

param.colorNames = colorNames;
param.cols = cols;


%% Conflict Levels
% confSet = round([linspace(param.cohRange(2),param.cohRange(1), param.confLevels/2), linspace(param.cohRange(1),param.cohRange(2),param.confLevels/2);...
%     ones(1,param.confLevels/2), ones(1,param.confLevels/2)*2]);

if param.confLevels == 2
    
    confSet = round(abs([linspace(param.cohRange(2), -1*param.cohRange(2), param.confLevels);...
        1,2]));
    
else
    
    confSet = round(abs([linspace(param.cohRange(2), -1*param.cohRange(2), param.confLevels);...
        ones(1,(param.confLevels-1)/2), 1, ones(1,(param.confLevels-1)/2)*2]));
end



% IF ONLY RANDOM, have the conflict randomly sampled with replacement,
% otherwise permute generative process
if param.rand && param.ordBl == 0
    
    confs = reshape(datasample(1:param.confLevels, param.nTr*param.nBl), [param.nTr, param.nBl]);
    
else
    
    [confs, data.task] = genGradShiftOuts(param.currOuts);
    
    for bl = 1:param.nBl
        
        % normalize conflict levels, and then scale to confLevel
        confs(:,bl) = (confs(:,bl) - min(confs(:,bl))) ./ range(confs(:,bl));
        confs(:,bl) = round(confs(:,bl) * param.confLevels);
        
        if param.rand % if random, permute ordered trials
            confs(:, bl) = confs(randperm(size(confs,1)), bl);
        end
        
    end
    
    confs(~confs) = 1; % remove 0s, so all real indices
    
end



data.confs = confs;


%% preallocate
[data.time.trOnset, data.task.color, data.task.motion, data.task.size, ...
    data.task.colorCoh, data.task.motionCoh, data.task.sizeCoh, ...
    data.task.corrResp, data.behav.resp, data.behav.rt, data.behav.acc, ...
    data.time.ITI] = deal(nan(param.nTr, param.nBl));

data.time.dotTime = nan(param.nTr, param.nBl, 2);

data.onsetMx = nan(param.nTr, param.nBl, size(onsetMx,1), size(onsetMx,2));


%% for each block
for bl = 1:param.nBl
    
    %% save block onset
    data.time.blOnset(bl) = fix(GetSecs);
    
    %% show instructions
    switch kind
        
        case {'ordered', 'random'}
            
            if mod(bl,2) == 1 || param.motionMainTr == 0
                
                task = 'COLOR';
                KeyMessage = KeyInfoColor;
                
                drawExampleColor(wPtr, screenInfo, param.expVers, cols)
                
                
                param.nTr = nTrOrig;
                
                
            else
                
                task = 'MOTION';
                KeyMessage = KeyInfoMotion;
                
                drawExampleMotion(wPtr, screenInfo, param.expVers)
                
                
                param.nTr = param.motionMainTr;
                
            end
            
            
        case 'color'
            
            task = 'COLOR';
            KeyMessage = KeyInfoColor;
            
            drawExampleColor(wPtr, screenInfo, param.expVers, cols)
            
            
            
            
        case 'motion'
            
            task = 'MOTION';
            KeyMessage = KeyInfoMotion;
            
            drawExampleMotion(wPtr, screenInfo, param.expVers)
            
            
    end
    
    %% reset color & motion durr
    prevCurCol = randi(4);
    prevMotDir = randi(4);
    
    
    %% DRAW INSTRUCTIONS (left right up down), show pictures!
    
    Screen('TextSize',wPtr,30);                                                                   % Sets text size
    
    if param.showBlockType % instruct participants about order/random
        DrawFormattedText(wPtr, upper(kind),...
            'center',Yres * .125, white, 70);
    end
    
    DrawFormattedText(wPtr, ['In this Section you will focus on '  task '. \n' ...               % Creates the text with inputs being screen number, message, X location, Y location, color, characters per line
        '\n\n' KeyMessage],...
        'center',Yres * .25, white, 70);
    
    DrawFormattedText(wPtr, ['Try to be as fast and accurate as possible' '\n\n' 'Press any key to begin'],...                                  % Creates the text with inputs being screen number, message, X location, Y location, color, characters per line
        'center',Yres * .88, white, 70);
    
    
    Screen(wPtr,'Flip');                                                                            % Flips everything onto the screen
    WaitSecs(2);                                                                                     % Waits a certain amount of time
    KbWait(-1);                                                                                    % Waits until any button is pressed
    
    Screen(wPtr,'Flip');                                                                        % Flips everything onto the screen    WaitSecs(2);
    WaitSecs(2);
    
    
    %% for each trial
    for tr = 1:param.nTr
        
        %trial onset
        data.time.trOnset(tr,bl) = fix(GetSecs);
        
        %% Set direction/coherence based on task
        switch kind
            
            case 'color'
                
                % set direction
                curCol = randsample(setdiff(1:4,prevCurCol), 1); %random color, dont repeat
                prevCurCol = curCol;
                dotInfo.dotColor = cols(curCol,:,1);
                
                motDir = randi(4); %random motion, dont repeat
                dotInfo.dir = dirs(1, motDir);
                %                 dotInfo.dir = randsample(dirs(1,:), 1); %random motion
                
                % set coherence
                dotInfo.colorCoh = 1000;
                dotInfo.coh = 0;
                
                % onset
                dotInfo.gradAtt.T0color     = -999;
                dotInfo.gradAtt.T0motion    = -999;
                
                
                % correct response
                data.task.corrResp(tr,bl) = respList(curCol);
                
                
                
            case 'motion'
                
                % set direction
                
                curCol = randi(4); %random color
                dotInfo.dotColor = cols(curCol,:,1);
                dotInfo.dotColor1 = randsample(setdiff(1:4, curCol), 1); %use another other random color
                
                motDir = randsample(setdiff(1:4, prevMotDir), 1); %random motion, dont repeat
                prevMotDir = motDir;
                dotInfo.dir = dirs(1, motDir);
                
                showDir = dotInfo.dir;
                
                % set coherence
                dotInfo.colorCoh = 0;
                dotInfo.coh = max(confSet(1,:));
                
                % onset
                dotInfo.gradAtt.T0color     = -999;
                dotInfo.gradAtt.T0motion    = -999;
                
                
                % correct response
                data.task.corrResp(tr,bl) = respList(motDir);
                
                
                
            case {'ordered', 'random'}
                
                switch task
                    
                    case 'COLOR'
                        
                        % set direction
                        curCol = randsample(setdiff(1:4,prevCurCol), 1); %random color, dont repeat
                        prevCurCol = curCol;
                        dotInfo.dotColor = cols(curCol,:,1);
                        motDir = 1;
                        dotInfo.dir = dirs(confSet(2, confs(tr,bl)), curCol); %set motion dir to match or mismatch color
                        
                        % set coherence
                        dotInfo.colorCoh = 1000;
                        dotInfo.coh = confSet(1, confs(tr,bl));
                        
                        % onset
                        onsetCond = randi(3); % which cond (both early, motion early, color early)
                        jitter = unifrnd(param.onsetJitter(1), param.onsetJitter(2));
                        dotInfo.gradAtt.T0color     = onsetMx(onsetCond,1)+jitter;
                        dotInfo.gradAtt.T0motion    = onsetMx(onsetCond,2)+jitter;
                        data.onsetMx(tr,bl,:,:) = onsetMx+jitter;
                        
                        
                        % correct response
                        data.task.corrResp(tr,bl) = respList(curCol);
                        
                        
                    case 'MOTION'
                        
                        % set direction
                        motDir = randsample(setdiff(1:4, prevMotDir), 1); %random motion, dont repeat
                        prevMotDir = motDir;
                        dotInfo.dir = dirs(1, motDir);
                        
                        
                        dotInfo.dotColor = cols(motDir,:,confSet(2, confs(tr,bl)));
                        dotInfo.dotColor1 = cols(motDir,:,2); %if 0 coh, use opposite color
                        curCol = mod(motDir + 2*(confSet(2, confs(tr,bl))-1), 4) + 1;
                        
                        %                         dotInfo.dir = dirs(confSet(2, confs(tr,bl)), dotInfo.curColor); %set motion dir to match or mismatch color
                        
                        % set coherence
                        dotInfo.colorCoh = confSet(1, confs(tr,bl));
                        dotInfo.coh = max(confSet(1,:));
                        
                        % onset
                        onsetCond = randi(3); % which cond (both early, motion early, color early)
                        jitter = randi(param.onsetJitter*1000)/1000;
                        dotInfo.gradAtt.T0color     = onsetMx(onsetCond,1)+jitter;
                        dotInfo.gradAtt.T0motion    = onsetMx(onsetCond,2)+jitter;
                        data.onsetMx(tr,bl,:,:) = onsetMx+jitter;
                        
                        
                        % correct response
                        data.task.corrResp(tr,bl) = respList(motDir);
                        
                end
                
                
                
        end
        
        
        %% set aperture shift
        if param.shiftAp == 1 & dotInfo.coh > 0
            dotInfo.apXYD(1:2) = apLoc(apLoc(:,3)==dotInfo.dir, 1:2);
        else
            dotInfo.apXYD(1:2) = [0,0];
        end
        
        
        %% set onset coh
        dotInfo.gradAtt.postT0mCoh = dotInfo.coh;
        
        
        %% Save task info
        % directions
        data.task.color(tr,bl)      = curCol;
        data.task.motion(tr,bl)     = dotInfo.dir;
        data.task.size(tr,bl)       = dotInfo.curSize;
        % coherences
        data.task.colorCoh(tr,bl)   = dotInfo.colorCoh;
        data.task.motionCoh(tr,bl)  = dotInfo.coh;
        data.task.sizeCoh(tr,bl)    = dotInfo.sizeCoh;
        % onset
        data.task.onsetCond(tr,bl)  = onsetCond;
        data.task.T0color(tr,bl)    = dotInfo.gradAtt.T0color;
        data.task.T0motion(tr,bl)   = dotInfo.gradAtt.T0motion;
        
        
        
        %% display parameters
        %                                 disp(['TR: '            num2str(tr)]);
        %                         disp(['BL: '            num2str(bl)]);
        %                         disp(['curr Color: '    colorNames(curCol)]);
        %                         disp(['curr dir: '      num2str(dotInfo.dir)]);
        %                         disp(['curr size: '     num2str(dotInfo.curSize)]);
        %                         disp(['curr colorCoh: ' num2str(dotInfo.colorCoh)]);
        %                         disp(['curr coh: '      num2str(dotInfo.coh)]);
        %                         disp(['curr sizeCoh: '  num2str(dotInfo.sizeCoh)]);
        %                         disp(['corr response: ' num2str(respList(motDir))]);
        %
        %                         disp(' ');
        
        %% Displays dots
        %         dotInfo.speed = [150, 150];
        %         dotInfo.coh = [900 900];
        %         dotInfo.dir = [180, 0];
        %         dotInfo.sizeCoh = [1000, 1000];
        %         dotInfo.gradAtt.postT0mCoh = [1000, 1000];
        %         dotInfo.gradAtt.postT0mDir = [180, 90];
        %         dotInfo.gradAtt.preT0mDir = [180, 90];
        %         dotInfo.gradAtt.postT0cCoh = [1000, 1000];
        %         dotInfo.colorCoh = [1000 1000];
        %         dotInfo.curColor = [0, 0];
        % dotInfo.numDotField = 2;
        dotInfo.frameDensity = [1]; % frame density, hack for multiple frames
        
        %         keyboard
        
        
        [~, ~, dotStart, dotEnd, response, rt] = dots3Task(screenInfo, dotInfo);  % Function to display the dots
        RestrictKeysForKbCheck([]); % checka all keys

        
        %  if abort, return data & close nicely
        if response{1} == 1
            
            data.behav.resp(tr,bl) = -999;
            data.behav.rt(tr,bl) = rt;
            data.time.dotTime(tr,bl,:) = fix([dotStart, dotEnd]);
            return;
            
        end
        
        
        
        
        
        %% save behaviour
        data.behav.resp(tr,bl) = response{3};
        data.behav.rt(tr,bl) = rt;
        data.time.dotTime(tr,bl,:) = fix([dotStart, dotEnd]);
        
        
        
        
        
        %% Show Feedback
        % calc feedback
        if data.behav.resp(tr,bl) == data.task.corrResp(tr,bl)   % If response is equal to answer
            data.behav.acc(tr,bl) = 1;                       % Set to 1 for correct
            feedback='CORRECT';                                             % Feedback to be displayed
            yLoc = 'center';
        elseif isnan(data.behav.resp(tr,bl))      % If response is a NaN from timing out
            data.behav.acc(tr,bl) = 0;                      % Set to 0 for timeout
            feedback='TIME OUT';                                            % Feedback to be displayed
            yLoc = Yres * .4;
        else
            data.behav.acc(tr,bl) = 0;                       % Set to 0 for incorrect
            feedback='INCORRECT';                                          % Feedback to be displayed
            yLoc = Yres * .4;
            
        end
        
        % draw feeback
        if param.feedback
            
            Screen('Flip', wPtr);
            DrawFormattedText(wPtr,feedback,'center',yLoc, white); % Creates the text with the feedback
            WaitSecs(0.25); %slight delay so feedback doesnt cooccur with dots
            
            %% show colors/lines if inaccurate
            if data.behav.acc(tr,bl) ~= 1
                switch kind
                    case 'color'
                        drawExampleColor(wPtr, screenInfo, param.expVers, cols);
                    case 'motion'
                        drawExampleMotion(wPtr, screenInfo, param.expVers);
                end
            end
            
            
            feedOn = Screen('Flip', wPtr);% Show feedback
            
            if data.behav.acc(tr,bl) == 1
                Screen('Flip',wPtr, feedOn + param.feedbackDur); %end feedback
            else
                Screen('Flip',wPtr, feedOn + param.errFeedDur); %end feedback
            end
            
            
        end
        
        Screen('TextSize',wPtr,50);
        DrawFormattedText(wPtr, '+', 'center', 'center', grey); % grey ITI
        data.time.ITI(tr,bl) = Screen('Flip', wPtr);
        
        data.task.ITI_len(tr,bl) = randi(param.ITI*1000)/1000; % ITI length
        
        DrawFormattedText(wPtr, '+', 'center', 'center', white); % 100ms cue
        Screen('Flip', wPtr, data.time.ITI(tr,bl) + (data.task.ITI_len(tr,bl) - param.startCue));
        
        Screen('TextSize',wPtr,30);
        WaitSecs(param.startCue); % cue onset
        
    end
    
    %% save current session
    save('CurrentSession');
    
    if param.nBl > 1 && bl < param.nBl
        
        DrawFormattedText(wPtr, ['End of Block' ...
            '\n\n\n' ...
            'Accuracy: ' num2str(nanmean(data.behav.acc(:,bl))*100, 3) '%' ...
            '\n' ...
            'Average Reaction Time: ' num2str(nanmedian(data.behav.rt(:,bl))*1000,'%3.4g') 'ms'...
            '\n\n' ...
            'Try to be as fast and accurate as possible',...
            '\n\n\n\n'...
            'Press any key to continue'], ...                                  % Creates the text with inputs being screen number, message, X location, Y location, color, characters per line
            'center','center',white,70);
        
        Screen(wPtr,'Flip');                                                   % Flips everything onto the screen
        WaitSecs(1);                                                           % Waits a certain amount of time
        KbWait(-1);                                                            % Waits until any button is pressed
        
        Screen(wPtr,'Flip');                                                                        % Flips everything onto the screen
        WaitSecs(2);
        
    end
    
    
    
    
end

%% store results
data.time.endTime = fix(clock);


DrawFormattedText(wPtr, ['End of Section ' '\n\n' 'Please inform the Experimenter '],...                                  % Creates the text with inputs being screen number, message, X location, Y location, color, characters per line
    'center','center',white,70);

Screen(wPtr,'Flip');                                                                            % Flips everything onto the screen
WaitSecs(1);                                                                                     % Waits a certain amount of time
KbWait(-1);                                                                                    % Waits until any button is pressed

end






function drawExampleColor(wPtr, screenInfo, expVers, cols)

Yres = screenInfo.screenRect(4);
Xres = screenInfo.screenRect(3);


locs = [...
    Xres/2 - 80 - 40,   Yres * .6 - 45 - 40,   Xres/2 - 80 + 40,   Yres * .6 - 45 + 40;...
    Xres/2 - 80 - 40,   Yres * .6 + 45 - 40,   Xres/2 - 80 + 40,   Yres * .6 + 45 + 40;...
    Xres/2 + 80 - 40,   Yres * .6 - 45 - 40,   Xres/2 + 80 + 40,   Yres * .6 - 45 + 40;...
    Xres/2 + 80 - 40,   Yres * .6 + 45 - 40,   Xres/2 + 80 + 40,   Yres * .6 + 45 + 40];



Screen('FillOval', wPtr, cols(:,:,1)', locs');
%  Screen('Flip',wPtr);

end



function drawExampleMotion(wPtr, screenInfo, expVers)

Yres = screenInfo.screenRect(4);
Xres = screenInfo.screenRect(3);


locs = [...
    Xres/2 - 80 - 40,   Yres * .6;  Xres/2 - 80 + 40,   Yres * .6; ... %left arrow
    Xres/2 - 80 - 40,   Yres * .6;  Xres/2 - 80 + 10,   Yres * .6 + 10; ...
    Xres/2 - 80 - 40,   Yres * .6;  Xres/2 - 80 + 10,   Yres * .6 - 10; ...
    
    Xres/2 + 80 - 40,   Yres * .6;  Xres/2 + 80 + 40,   Yres * .6;...%right arrow
    Xres/2 + 80 + 40,   Yres * .6;  Xres/2 + 80 - 10,   Yres * .6 + 10;...
    Xres/2 + 80 + 40,   Yres * .6;  Xres/2 + 80 - 10,   Yres * .6 - 10];


Screen('DrawLines', wPtr, locs', 5);
% Screen('Flip',wPtr);

end



function [outs, task] = genGradShiftOuts(param)
% create new PID outcomes

rng('shuffle','twister');
nTr = param.nTr;
nBl = param.nBl;

%% task param
% locations
locHaz = param.locHaz;
locRange = param.locRange;

% transitions
transLen = [param.transMin, param.transMin + param.transRange];

% variances
varHaz = param.varHaz;
varRange = [param.varMin, param.varMin + param.varRange];

%% preallocate
[outs, task.transFlag, task.VarTr, task.LocTr] = deal(nan(nTr, nBl));

%% for each block
for bl = 1:nBl
    
    
    % reset parameters
    locTr = randi([-180 180]);    % curent mean
    
    varTr = randi(varRange);    % current var
    
    %reset counters
    transCount = 1;
    transFlag = 0;
    
    
    %% for each trial
    for tr = 1:nTr
        
        
        if rand < varHaz %if new var
            
            varTr = randi(varRange);    % new var
            
        end
        
        if ~transFlag %if not transition
            
            if rand < locHaz % if new mean
                
                newLoc = locTr + randi(locRange);    % new mean
                
                transDur = randi(transLen); % duration of transition
                
                transLoc = linspace(locTr, newLoc, transDur); % transition locations (linear spaces between old and new locs)
                
                
                transCount = 1;
                transFlag = 1;
                
            end
            
        end
        
        if transFlag %if transition
            
            if transCount > transDur
                
                transFlag = 0;
                
            else
                
                locTr = transLoc(transCount);
                transCount = transCount + 1;
                
            end
            
        end
        
        outs(tr, bl) = (randn * varTr) + locTr;
        
        task.transFlag(tr, bl) = transFlag;
        task.VarTr(tr, bl) = varTr;
        task.LocTr(tr, bl) = locTr;
        
        
    end
end


end











%% THE FAMOUS dotsX SCRIPT

function [frames, rseed, start_time, end_time, response, response_time, dotArraySize] = dots3Task(screenInfo, dotInfo, targets)

% [frames, rseed, start_time, end_time, response, response_time] =
% dotsX(screenInfo, dotInfo, targets)
% targets optional.
%
% arguments - minimum fields for dotInfo and screenInfo - see createDotInfo
% and openExperiment
%
%   most everything is in visual degrees * 10, since rex only likes integers
%
%       dotInfo.numDotField     number of dot patches that will be shown on the screen
%		dotInfo.coh             vertical vectors, dots coherence (0...999) for each dot patch
%		dotInfo.speed           vertical vectors, dots speed (10th deg/sec) for each dot patch
%		dotInfo.dir             vertical vectors, dots direction (degrees) for each dot patch
%       dotInfo.dotSize         size of dots in pixels, same for all patches
%       dotInfo.dotColor        color 1 of dots in rgb, same for all patches
%       dotInfo.dotColor2       *AS* color 2 of dots in rgb, same for all patches
%       dotInfo.dotColor3       *AS* color 3 of dots in rgb, same for all patches (intended for coming out of grad attention)
%       dotInfo.pctColor3       *AS* % of dots pre-allocated to color 3 (intended for coming out of grad attention)
%       dotInfo.pctColor3dec    *AS* decrease per frame for % of dots pre-allocated to color 3 (intended for coming out of grad attention)
%       dotInfo.pctMotionJitter  *AS* % of dots jittering around a mean location (intended for coming out of grad attention)
%       dotInfo.pctMotionJitterDec  *AS* decrease per frame for % of dots jittering (intended for coming out of grad attention)
%       dotInfo.rejectUnequalStarts *AS* based on Kayser et al., 2010, guarantee equal spacing across 4x4 grid
%       dotInfo.maxDotsPerFrame determined by testing video card
%       dotInfo.apXYD           x, y coordinates, and diameter of aperture(s) in visual degrees
%		dotInfo.maxDotTime      optional, can set maximum duration (sec).
%		                        if not, dot presentation terminated only by user response
%       dotInfo.trialtype       1 fixed duration, 2 reaction time
%       dotInfo.keys            a set of keyboard buttons that can
%                               terminate the presentation of dots (optional)
%       dotInfo.mouse           a set of mouse buttons that can terminate
%                               the presentation of dots (optional)
%		RETIRED: dotInfo.pctColor1       *AS* percent of dots colored as dotColor1 (vs. color2)
%       dotInfo.colorCoh        *AS* pct of dots w/ coherent color (vs. randomly assigned)
%		dotInfo.dotsPerSqDeg    *AS* Number of dots per video frame = XX dots per sq.deg/sec,
%       dotInfo.apFrameWidth    *AS* Width of frame around aperture to cover edge effects of dots (set to nan to omit)
%       dotInfo.apFrameScale    *AS* Scale factor for frame around aperture (relative to actual aperture size)
%       dotInfo.showAfterRT     *AS* Continue stim display till max RT regardless of RT
%
%       dotInfo.sizeCoh       *SM* coherence of the size of the dots (0...999) for each dot patch
%       dotInfo.dotSizeSet     *SM* specifies the two different dot sizes
%       dotInfo.curSize *SM* specifies which dot size is the dominant one
%
%       dotInfo.gradAtt.t0cColor
%       dotInfo.gradAtt.t0mSpeed
%       dotInfo.gradAtt.pret0col
%       dotInfo.gradAtt.pret0speed
%
%       screenInfo.curWindow    window on which to plot dots
%       screenInfo.center       center of the screen in pixels
%       screenInfo.ppd          pixels per visual degree
%       screenInfo.monRefresh   monitor refresh value
%       screenInfo.dontclear    If set to 1, flip will not clear the framebuffer after Flip - this allows incremental
%                               drawing of stimuli. Needs to be zero for dots to be erased.
%		screenInfo.rseed        random # seed, can be empty set[]
%
%       targets structure not necessary if not showing targets with the
%       dots
%       targets.rects   dimensions for drawOval
%       targets.colors  color of targets
%       targets.show    optional, if only showing certain targets but don't
%            want to change targets structure (index number of target(s) to be
%            shown during dots
%
% algorithm:
%		All calculations take place within a square aperture
% in which the dots are shown. The dots are constructed in 3 sets that are
% plotted in sequence.  For each set, the probability that a dot is
% replotted in motion -- as opposed to randomly replaced -- is given by the
% dotInfo.coh value.  This routine generates a set of dots as an ndots_ by
% 2 matrix of locations, and then plots them.  In plotting the next set of
% dots (e.g., set 2) it prepends the preceding set (e.g., set 1).
%
% created by MKMK July 2006, based on ShadlenDots by MNS, JIG and others

% structures are not altered in this function, so should not have memory
% problems from matlab creating new structures...

% CURRENTLY THERE IS AN ALMOST ONE SECOND DELAY FROM THE TIME DOTSX IS
% CALLED UNTIL THE DOTS START ON THE SCREEN! THIS IS BECAUSE OF PRIORITY.
% NEED TO EVALUATE WHETHER PRIORITY IS REALLY NECESSARY.
%


%% delay colors
% if dotInfo.colorDelay
%     color = dotInfo.dotColor;
%     color2 = dotInfo.dotColor2;
%
%     dotInfo.dotColor = [.5 .5 .5];
%     dotInfo.dotColor2 = [.5 .5 .5];
% end



dotsX_callStart = GetSecs;

%mfilename
%test = GetSecs;
if nargin < 3
    targets = [];
    showtar = [];
else
    if isfield(targets,'show')
        showtar = targets.show;
    else
        showtar = 1:size(targets.rects,1);
    end
end

if ~isfield(dotInfo, 'apFrameWidth')
    dotInfo.apFrameWidth = nan;
    dotInfo.apFrameScale = nan;
end
if ~isfield(dotInfo, 'showAfterRT')
    dotInfo.showAfterRT = 0; % continue stim display till max RT regardless of RT
end

if ~isfield(dotInfo, 'isFrozArray')
    % ALSO SET RSEED AND SET BACK TO [] AFTER
    dotInfo.isFrozArray = 0; % set up as frozen array w/ changing colors
end

if ~isfield(dotInfo, 'dotColor3')
    dotInfo.dotColor3 = [137 137 137];
end
if ~isfield(dotInfo, 'pctDot3')
    dotInfo.pctColor3 = 0;
end
if ~isfield(dotInfo, 'pctColor3dec')
    dotInfo.pctColor3dec = 0;
end
if ~isfield(dotInfo, 'pctMotionJitter')
    dotInfo.pctMotionJitter = 0;
end
if ~isfield(dotInfo, 'pctMotionJitterDec')
    dotInfo.pctMotionJitterDec = 0;
    dotInfo.speedDec = 0;
end
if ~isfield(dotInfo, 'rejectUnequalStarts')
    dotInfo.rejectUnequalStarts = 0;
end
if ~isfield(dotInfo, 'allowContinuedKeyCheck')
    dotInfo.allowContinuedKeyCheck = 0;  % Previous default (e.g., for 1st MRI study) was unwittingly to continue accepting
end


%% ASSIGN KEYS

keys = [dotInfo.keyLeft, dotInfo.keyUp, dotInfo.keyRight, dotInfo.keyDown];
abort = [KbName('q')];

RestrictKeysForKbCheck([keys, abort]);
RestrictKeysForKbCheck([]);


%% TURNED OFF BELOW!!!! CHECK IF STATEMENT!!!
% AS (for gradual attention/evidence onset):

% Need to adjust array sizes for multiple dot fields!!
dotInfo.gradAtt.preT0col1 = [175 175 175];
dotInfo.gradAtt.preT0col2 = [175 175 175];
dotInfo.gradAtt.preT0cCoh = 0;
dotInfo.gradAtt.preT0curColor = [175 175 175];
% NEED TO INSTEAD REMOVE LOCATION UPDATES!
dotInfo.gradAtt.preT0mCoh = 0.0*1000;
%     dotInfo.gradAtt.preT0speed = 0;
dotInfo.gradAtt.preT0speed = dotInfo.speed;
dotInfo.gradAtt.preT0mDir = dotInfo.dir;

dotInfo.gradAtt.postT0cCoh = dotInfo.colorCoh;
dotInfo.gradAtt.postT0col1 = dotInfo.dotColor;
dotInfo.gradAtt.postT0col2 = dotInfo.dotColor2;
dotInfo.gradAtt.postT0curColor = dotInfo.curColor;
dotInfo.gradAtt.postT0mCoh = dotInfo.coh; % need to deal w/ div 1000
dotInfo.gradAtt.postT0speed = dotInfo.speed;
dotInfo.gradAtt.postT0mDir = dotInfo.dir;

% dotInfo.gradAtt.transitionTime = 10/screenInfo.monRefresh; % secs
% dotInfo.gradAtt.transitionTime = 50/screenInfo.monRefresh; % secs
%%%% REMOVE THESE - only for testing!
% %         dotInfo.gradAtt.postT0mCoh = 500; % need to deal w/ div 1000
% %         dotInfo.maxDotTime = 10;
if ~isfield(dotInfo.gradAtt,'T0color')
    dotInfo.gradAtt.T0color = -999; % secs
end

if ~isfield(dotInfo.gradAtt,'T0motion')
    dotInfo.gradAtt.T0motion = -999; % secs
end
if dotInfo.gradAtt.T0color>0
    
    dotInfo.gradAtt.Con = 0;% color channel off
    % TEST!
    %     dotInfo.dotColor = dotInfo.gradAtt.preT0col1;
    %     dotInfo.dotColor2 = dotInfo.gradAtt.preT0col2;
    %     dotInfo.curColor = dotInfo.gradAtt.preT0curColor;
    %     dotInfo.colorCoh = dotInfo.gradAtt.preT0cCoh;
    
    dotInfo.dotColor3 = dotInfo.gradAtt.preT0curColor;
    dotInfo.pctColor3 = 1.0;
else
    dotInfo.gradAtt.Con = 1; % color channel on
    dotInfo.dotColor = dotInfo.gradAtt.postT0col1;
    dotInfo.dotColor2 = dotInfo.gradAtt.postT0col2;
    dotInfo.curColor = dotInfo.gradAtt.postT0curColor;
    dotInfo.colorCoh = dotInfo.gradAtt.postT0cCoh;
    dotInfo.pctColor3 = 0;
end

if dotInfo.gradAtt.T0motion>0
    if dotInfo.gradAtt.T0motion>5000
        dotInfo.gradAtt.T0motion = dotInfo.gradAtt.T0motion-5000;
        dotInfo.gradAtt.useStaticMotion = 1;
        dotInfo.gradAtt.staticMotionColorFlip = 20; % change color every X frames when motion frozen
        dotInfo.gradAtt.preT0speed = 0;
        dotInfo.pctMotionJitter = 0;
        dotInfo.gradAtt.transitionTime = 5/screenInfo.monRefresh; % secs
    else
        dotInfo.gradAtt.useStaticMotion = 0;
        dotInfo.gradAtt.staticMotionColorFlip = 1;
        dotInfo.pctMotionJitter = 0;
        dotInfo.gradAtt.transitionTime = 5/screenInfo.monRefresh; % secs
    end
    
    dotInfo.gradAtt.Mon = 0; % motion channel off
    dotInfo.coh = dotInfo.gradAtt.preT0mCoh;
    dotInfo.speed = dotInfo.gradAtt.preT0speed;
    dotInfo.dir = dotInfo.gradAtt.preT0mDir;
else
    dotInfo.gradAtt.transitionTime = 5/screenInfo.monRefresh; % secs
    
    dotInfo.gradAtt.Mon = 1; % motion channel on
    dotInfo.coh = dotInfo.gradAtt.postT0mCoh;
    dotInfo.speed = dotInfo.gradAtt.postT0speed;
    dotInfo.dir = dotInfo.gradAtt.postT0mDir;
    dotInfo.gradAtt.useStaticMotion = 0;
    dotInfo.gradAtt.staticMotionColorFlip = 1;
    dotInfo.pctMotionJitter = 0;
end

dotInfo.pctMotionJitter = ones(1, dotInfo.numDotField) * dotInfo.pctMotionJitter;


dotInfo.gradAtt.postT0cPctDec = -1/(dotInfo.gradAtt.transitionTime*screenInfo.monRefresh);
dotInfo.gradAtt.postT0mPctDec = -1/(dotInfo.gradAtt.transitionTime*screenInfo.monRefresh);


curWindow = screenInfo.curWindow;
% dotColor = dotInfo.dotColor;  % NOW a struct!
rseed = screenInfo.rseed;

% this only matters if using mouse, if dotInfo.mouse doesn't exist, this is
% never checked.
if dotInfo.trialtype(2) == 2
    waitpress = 1; % 1 means wait for a mouse press
else
    waitpress = 0; % 0 means wait for release
end
% to find out if using keypress or mouse, all trials should have spacekey
% for abort, unless its a demo.

% spacekey means end experiment after this trial - sends abort message to
% experiment

% % CHANGED BY AS (3/4/13) to disallow keys w/ fixed time:
% if isfield(dotInfo, 'keyLeft') && dotInfo.trialtype(1)~=1
% % if isfield(dotInfo, 'keyLeft')
%     keys = [dotInfo.keyLeftLeft dotInfo.keyLeftRight dotInfo.keyRightLeft dotInfo.keyRightRight];
% elseif ~isfield(dotInfo, 'keySpace')
%     abort = nan;
% end

%%  mouse
if isfield(dotInfo, 'mouse')
    mouse = dotInfo.mouse;
else
    mouse = [];
end

start_time = NaN;
end_time= NaN;
response = {NaN, NaN NaN};
response_time = NaN;



if isfield(targets,'select')
    h = targets.select(:,1);
    k = targets.select(:,2);
    r = targets.select(:,3);
end
% SEED THE RANDOM NUMBER GENERATOR ... if "[]" is given, reset
% the seed "randomly"... this is for VAR/NOVAR conditions
if ~isempty(rseed) && length(rseed) == 1
    rand('state', rseed);
elseif ~isempty(rseed) && length(rseed) == 2
    rand('state', rseed(1)*rseed(2));
else
    rseed = sum(100*clock);
    rand('state', rseed);
end
if dotInfo.isFrozArray
    RandStream.setDefaultStream(RandStream('mt19937ar','Seed',rseed)); %reset the random number generator
end
% create the square for the aperture
apRect = repmat(floor(createTRect(dotInfo.apXYD, screenInfo)), [dotInfo.numDotField, 1]);

for df=1:size(apRect,1)
    apRectBigger(df,:)=CenterRect(ScaleRect(apRect(df,:),dotInfo.apFrameScale,dotInfo.apFrameScale),apRect(df,:));
end

% USEFUL LOCAL VARS
% variables that are sent to rex have been multiplied by a factor of 10 to
% make sure they are integers. Now we have to convert them back so that
% they are correct for plotting.
coh   	= dotInfo.coh/1000;	%  % dotInfo.coh is specified on 0... (because
% of rex needing integers), but we want 0..1

apD = dotInfo.apXYD(:,3); % diameter of aperture
% dotInfo.apXYD(:,1:2)
% screenInfo.center;
% disp('dotInfo.apXYD')
% dotInfo.apXYD(:,1:2)/10*screenInfo.ppd
% size(screenInfo.center);
center = repmat(screenInfo.center,size(dotInfo.apXYD(:,1)));
% size(dotInfo.apXYD(:,1:2));
% change the xy coordinates to pixels (y is inverted - pos on bottom, neg.
% on top
center = [center(:,1) + dotInfo.apXYD(:,1)/10*screenInfo.ppd center(:,2) - dotInfo.apXYD(:,2)/10*screenInfo.ppd]; % where you want the center of the aperture
d_ppd 	= floor(apD/10 * screenInfo.ppd);	% size of aperture in pixels
dotSize{1} = dotInfo.dotSize; % probably better to leave this in pixels, but not sure
%dotSize = screenInfo.ppd*dotInfo.dotSize/10;
% ndots is the number of dots shown per video frame
% we will place dots in a square the size of the aperture
% - Size of aperture = Apd*Apd/100  sq deg
% - Number of dots per video frame = 16.7 dots per sq.deg/sec,
%        Round up, do not exceed the number of dots that can be
%		 plotted in a video frame (dotInfo.maxDotsPerFrame)
% maxDotsPerFrame was originally in setupScreen as a field in screenInfo,
% but makes more sense in createDotInfo as a field in dotInfo
% keyboard
% ndots 	= min(dotInfo.maxDotsPerFrame, ceil(16.7 * apD .* apD * 0.01 / screenInfo.monRefresh)); %HR - OLD, assume equal density across frames
ndots 	= ones(1, dotInfo.numDotField) * min(dotInfo.maxDotsPerFrame, ceil(dotInfo.dotsPerSqDeg * apD .* apD * 0.01 / screenInfo.monRefresh)); %HR make ndots value for each frame
ndots = round(ndots .* dotInfo.frameDensity); %% HR -- for multiple frames



% don't worry about pre-allocating, the number of dot fields should never
% be large enough to cause memory problems

for df = 1 : dotInfo.numDotField,
    % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
    %    	 deg/sec     * Ap-unit/deg  * sec/jump   =   unit/jump
    dxdy{df} 	= repmat((dotInfo.speed(df)/10) * (10/apD) * (3/screenInfo.monRefresh) ... %assume apD (apature size) is constant across frames
        * [cos(pi*dotInfo.dir(df)/180.0) -sin(pi*dotInfo.dir(df)/180.0)], ndots(df), 1);
    
    if ~dotInfo.rejectUnequalStarts
        % ARRAYS, INDICES for loop
        ss{df}		= rand(ndots(df)*3, 2); % array of dot positions raw [xposition yposition]
        % divide dots into three sets...
        Ls{df}      = cumsum(ones(ndots(df),3))+repmat([0 ndots(df) ndots(df)*2], ndots(df), 1);
    else
        %%% NOTE THAT rejectUnequalStarts can be 1 if only interested in 1st frame or 3 if interested in all 3 frames
        %%% made this adjustment on 4/27/14
        
        % Re-randomizing initial positions if unusually skewed
        while 1
            % ARRAYS, INDICES for loop
            ss{df}		= rand(ndots(df)*3, 2); % array of dot positions raw [xposition yposition]
            % divide dots into three sets...
            Ls{df}      = cumsum(ones(ndots(df),3))+repmat([0 ndots(df) ndots(df)*2], ndots(df), 1);
            
            framePassesChi2 = zeros(1,3);
            %             for llii = 1:3
            for llii = 1:3
                tmpThis_s{df} = ss{df}(Ls{df}(:,llii),:); % this is a matrix of random #s - starting positions for dots not moving coherently
                if llii<=dotInfo.rejectUnequalStarts
                    tmpCoords=ceil(tmpThis_s{df}/0.25);  % coords in 4x4 grid
                    tmpCoords(:,3)=(tmpCoords(:,1)-1)*4+tmpCoords(:,2);  % coords in 1x16
                    
                    [tmpChi2, tmpCriticalChi2] = chi2test(tmpCoords(:,3)',16,0.05,'unif',1,16);  %
                    if tmpChi2<tmpCriticalChi2
                        framePassesChi2(llii) = 1;
                    end
                end
            end
            %%% NOTE THAT
            %             if mean(framePassesChi2)==1
            if dotInfo.rejectUnequalStarts==1 && framePassesChi2(1)==1
                break;
            elseif dotInfo.rejectUnequalStarts==3 && mean(framePassesChi2)==1
                break;
            end
        end
    end
    loopi(df)   = 1; 	% loops through the three sets of dots
end;
% if dotInfo.gradAtt.useStaticMotion
smLoopi = 0;
% end
%disp('after one loop')
% loop length is determined by the field "dotInfo.maxDotTime"
% if none given, loop until "continue_show=0" is set by other means (eg
% user response), otherwise loop until dotInfo.maxDotTime
% always one video frame per loop

if ~isfield(dotInfo,'maxDotTime') || (isempty(dotInfo.maxDotTime) && ndots>0),
    continue_show = -1;
elseif ndots > 0,
    continue_show = round(dotInfo.maxDotTime*screenInfo.monRefresh);
else
    continue_show = 0;
end;

dontclear = screenInfo.dontclear;

% THE MAIN LOOP
frames = 0;
priorityLevel = MaxPriority(curWindow,'KbCheck');
Priority(priorityLevel);
index = 0;

% make sure the fixation still on
for i = showtar
    Screen('FillOval', screenInfo.curWindow, targets.colors(i,:), targets.rects(i,:));
end
Screen('DrawingFinished',curWindow,dontclear);

if dotInfo.isFrozArray
    continue_show = 0; % SKIPPING main RDK stuff
end


% how dots are presented: 1 group of dots are shown in the first frame, a
% second group are shown in the second frame, a third group shown in the
% third frame, then in the next frame, some percentage of the dots from the
% first frame are replotted according to the speed/direction and coherence,
% the next frame the same is done for the second group, etc.

%GetSecs - test

while continue_show
    if dotInfo.speed(1)>0 || frames<=0  % Change back to >0, use first speed param
        for df = 1 : dotInfo.numDotField,
            % ss is the matrix with the 3 sets of dot positions, dots from the last 2 positions + current
            % Ls picks out the set (for ex., with 5 dots on the screen at a time, 1:5, 6:10, or 11:15)
            if ~dotInfo.gradAtt.useStaticMotion
                Lthis{df}  = Ls{df}(:,loopi(df));  % Lthis now has the dot positions from 3 frames ago, which is what is then
            else
                Lthis{df}  = Ls{df}(:,:);  % Lthis now has the dot positions from 3 frames ago, which is what is then
            end
            % moved in the current loop
            
            %         try
            this_s{df} = ss{df}(Lthis{df},:); % this is a matrix of random #s - starting positions for dots not moving coherently
            %         catch tmpme
            %             keyboard
            %         end
            % update the loop pointer
            loopi(df) = loopi(df)+1;
            if dotInfo.gradAtt.useStaticMotion
                smLoopi = smLoopi+1;
                if smLoopi == dotInfo.gradAtt.staticMotionColorFlip
                    smLoopi = 1;
                end
            end
            if loopi(df) == 4,
                loopi(df) = 1;
            end
            % compute new locations, how many dots move coherently
            L = rand(ndots(df),1) < coh(df);
            if dotInfo.pctMotionJitter(df)==0  % Not jittering in place
                this_s{df}(L,:) = this_s{df}(L,:) + dxdy{df}(L,:);	% offset the selected dots
                if sum(~L) > 0
                    this_s{df}(~L,:) = rand(sum(~L),2);	    % get new random locations for the rest
                end
            else
                L=double(L);
                L(1:round(dotInfo.pctMotionJitter(df)*length(L))) = 99; % dot color 1 = 0
                L = L(randperm(length(L)));
                this_s{df}(L==1,:) = this_s{df}(L==1,:) + dxdy{df}(L==1,:);	% offset the selected dots
                if sum(L==99) > 0
                    % Randomly adding positive or negative jitter
                    this_s{df}(L==99,:) = this_s{df}(L==99,:) + sign(rand(length(find(L==99)),2)-0.5).*dxdy{df}(L==99,:);	% offset the selected dots
                end
                if sum(L==0) > 0
                    this_s{df}(L==0,:) = rand(sum(L==0),2);	    % get new random locations for the rest
                end
            end
            % wrap around - check to see if any positions are greater than one or less than zero
            % which is out of the square aperture, and then replace with a dot along one
            % of the edges opposite from direction of motion.
            N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
            if sum(N) > 0
                xdir = sin(pi*dotInfo.dir(df)/180.0);
                ydir = cos(pi*dotInfo.dir(df)/180.0);
                % flip a weighted coin to see which edge to put the replaced
                % dots
                if rand < abs(xdir)/(abs(xdir) + abs(ydir))
                    this_s{df}(find(N==1),:) = [rand(sum(N),1) (xdir > 0)*ones(sum(N),1)];
                else
                    this_s{df}(find(N==1),:) = [(ydir < 0)*ones(sum(N),1) rand(sum(N),1)];
                end
            end
            % convert to stuff we can actually plot
            this_x{df} = floor(d_ppd * this_s{df});	% pix/ApUnit --- HR: assume constant d_ppd across frames
            
            % this assumes that zero is at the top left, but we want it to be
            % in the center, so shift the dots up and left, which just means
            % adding half of the aperture size to both the x and y direction.
            dot_show{df} = (this_x{df} - d_ppd/2)';
        end;
    else
        for df = 1 : dotInfo.numDotField,
            tmpcoh(df) =  0.9;
            %             tmpcoh(df) =  0.3;
            if mod(frames,2)==0
                tmpdir(df) = 90;
            else
                tmpdir(df) = 270;
            end
            
            if ~dotInfo.gradAtt.useStaticMotion
                Lthis{df}  = Ls{df}(:,loopi(df));  % Lthis now has the dot positions from 3 frames ago, which is what is then
            else
                Lthis{df}  = Ls{df}(:,:);  % Lthis now has the dot positions from 3 frames ago, which is what is then
            end
            this_s{df} = ss{df}(Lthis{df},:); % this is a matrix of random #s - starting positions for dots not moving coherently
            loopi(df) = loopi(df)+1;
            if loopi(df) == 4,
                loopi(df) = 1;
            end
            if dotInfo.gradAtt.useStaticMotion
                smLoopi = smLoopi+1;
                if smLoopi == dotInfo.gradAtt.staticMotionColorFlip
                    smLoopi = 1;
                end
            end
            
            % compute new locations, how many dots move coherently
            L = rand(ndots(df),1) < tmpcoh(df);
            this_s{df}(L,:) = this_s{df}(L,:) + dxdy{df}(L,:);	% offset the selected dots
            if sum(~L) > 0
                this_s{df}(~L,:) = rand(sum(~L),2);	    % get new random locations for the rest
            end
            N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
            if sum(N) > 0
                xdir = sin(pi*tmpdir(df)/180.0);
                ydir = cos(pi*tmpdir(df)/180.0);
                % flip a weighted coin to see which edge to put the replaced dots
                if rand < abs(xdir)/(abs(xdir) + abs(ydir))
                    this_s{df}(find(N==1),:) = [rand(sum(N),1) (xdir > 0)*ones(sum(N),1)];
                else
                    this_s{df}(find(N==1),:) = [(ydir < 0)*ones(sum(N),1) rand(sum(N),1)];
                end
            end
            
            this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
            dot_show{df} = (this_x{df} - d_ppd(df)/2)';
        end
    end
    % after all computations, flip, this draws dots from previous loop,
    % first time through doesn't do anything
    Screen('Flip', curWindow,0,dontclear);
    
    
    % ===== FIXATION
    %     Screen('DrawText', curWindow, '+', screenInfo.center(1), screenInfo.center(2), [0,0,0]);
    
    
    
    if screenInfo.showAttendCues
        Screen(screenInfo.curWindow,'TextSize',screenInfo.cueTextSize);
        % ADJUST COLOR HERE AND BELOW:
        %%%% NEED TO ADD CUE COLOR INPUT!!!
        %         Screen(screenInfo.curWindow,'DrawText',dotInfo.curAttendCue,screenInfo.center(1),screenInfo.center(2), [255,255,255]);%dotInfo.dotColor);
        DrawFormattedText(curWindow, '+', 'center', 'center', [255,255,255]);
        
        
    end
    % setup the mask - we will only be able to see a circular aperture,
    % although dots moving in a square aperture. Minimizes the edge
    % effects.
    Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);
    
    % want targets to still show up
    Screen('FillRect', curWindow, [0 0 0 255]);
    
    for df = 1 : dotInfo.numDotField,
        % square that dots do not show up in
        Screen('FillRect', curWindow, [0 0 0 0], apRectBigger(df,:));
        % % %         Screen('FillRect', curWindow, [0 0 0 0], ScaleRect(apRect(df,:),1.1,1.1));
        % circle that dots do show up in
        Screen('FillOval', curWindow, [0 0 0 255], apRect(df,:));
    end
    
    Screen('BlendFunction', curWindow, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    
    % now do actual drawing commands, although nothing drawn until next
    % loop
    % dots
    
    
    if screenInfo.showAttendCues
        Screen(screenInfo.curWindow,'TextSize',screenInfo.cueTextSize);
        %%%% NEED TO ADD CUE COLOR INPUT!!!
        %         Screen(screenInfo.curWindow,'DrawText',dotInfo.curAttendCue,screenInfo.center(1),screenInfo.center(2),[255,255,255]);%dotInfo.dotColor);
        DrawFormattedText(curWindow, '+', 'center', 'center', [255,255,255]);
        
    end
    
    for df = 1:dotInfo.numDotField
        % AS:
        %         keyboard
        %         dotColor = repmat([255 0 0],size(dot_show{df},2),1)';
        
        % Remove 0 and 1 below to start running
        if ~isnan(dotInfo.colorCoh(df)) && ~(dotInfo.gradAtt.useStaticMotion && smLoopi>1)
            %             dotInfo.colorCoh,  dotInfo.curColor
            
            
            % ADJUST DOT SIZE
            if(isfield(dotInfo, 'sizeCoh') && isfield(dotInfo, 'dotSizeSet') && isfield(dotInfo, 'curSize'))
                % specify dot size
                % which size is most prominent?
                dominantSize = dotInfo.dotSizeSet(dotInfo.curSize);
                
                weakSize = dotInfo.dotSizeSet(dotInfo.dotSizeSet ~= dotInfo.dotSizeSet(dotInfo.curSize));
                
                % generate size vector proportional to coherence
                tmpDotSizes = dotInfo.dotSizeSet (randi(length(dotInfo.dotSizeSet), 1,size(dot_show{df},2)));
                tmpDotSizes_dominantIdx = (rand(1,size(dot_show{df},2)))<(dotInfo.sizeCoh(df)/1000);
                tmpDotSizes(tmpDotSizes_dominantIdx) = dominantSize;
                
                dotSize{df} = tmpDotSizes;
                
            else
                dotSize{df} = dotInfo.dotSize;
            end
            
            tmpDotColors = round(rand(1,size(dot_show{df},2)));
            % Move div by 1000 up earlier
            cohColInds = (rand(1,size(dot_show{df},2)))<(dotInfo.colorCoh(df)/1000);
            tmpDotColors(cohColInds) = dotInfo.curColor(df);
            
            dotColor{df} = ones(3,size(dot_show{df},2));
            dotColor{df}(:,tmpDotColors==0) = repmat(dotInfo.dotColor',1,length(find(tmpDotColors==0)));
            dotColor{df}(:,tmpDotColors==1) = repmat(dotInfo.dotColor2',1,length(find(tmpDotColors==1)));
            if dotInfo.pctColor3>0
                tmpDotColors(1:round(dotInfo.pctColor3(df)*length(tmpDotColors))) = 99; % dot color 1 = 0
                tmpDotColors = tmpDotColors(randperm(length(tmpDotColors)));
                dotColor{df}(:,tmpDotColors==99) = repmat(dotInfo.dotColor3',1,length(find(tmpDotColors==99)));
            end
            if frames == 0
                dotArraySize = length(tmpDotColors);
            end
        end
        
        if frames == 0 && (isnan(dotInfo.colorCoh(df)))
            % %             if 0
            % % %                 dotInfo.colorCoh,  dotInfo.curColor
            % %                 tmpDotColors = round(rand(1,size(dot_show{df},2)));
            % %                 cohColInds = (rand(1,size(dot_show{df},2)))<dotInfo.colorCoh;
            % %                 tmpDotColors(cohColInds) = dotInfo.curColor;
            % %
            % %                 dotArraySize = length(tmpDotColors);
            % %                 tmpDotColors(1:round(dotInfo.pctColor1(df)*length(tmpDotColors))) = 0; % dot color 1 = 0
            % %                 tmpDotColors = tmpDotColors(randperm(length(tmpDotColors)));
            % %                 dotColor{df} = ones(3,size(dot_show{df},2));
            % %                 dotColor{df}(:,tmpDotColors==0) = repmat(dotInfo.dotColor',1,length(find(tmpDotColors==0)));
            % %                 dotColor{df}(:,tmpDotColors==1) = repmat(dotInfo.dotColor2',1,length(find(tmpDotColors==1)));
            % %             end
            
            if dotInfo.pctColor1(df)==1
                dotColor{df} = dotInfo.dotColor;
            else
                %                 keyboard
                tmpDotColors = ones(1,size(dot_show{df},2));
                dotArraySize = length(tmpDotColors);
                tmpDotColors(1:round(dotInfo.pctColor1(df)*length(tmpDotColors))) = 0; % dot color 1 = 0
                tmpDotColors = tmpDotColors(randperm(length(tmpDotColors)));
                dotColor{df} = ones(3,size(dot_show{df},2));
                dotColor{df}(:,tmpDotColors==0) = repmat(dotInfo.dotColor',1,length(find(tmpDotColors==0)));
                dotColor{df}(:,tmpDotColors==1) = repmat(dotInfo.dotColor2',1,length(find(tmpDotColors==1)));
                if dotInfo.pctColor3>0
                    tmpDotColors(1:round(dotInfo.pctColor3(df)*length(tmpDotColors))) = 99; % dot color 1 = 0
                    tmpDotColors = tmpDotColors(randperm(length(tmpDotColors)));
                    dotColor{df}(:,tmpDotColors==99) = repmat(dotInfo.dotColor3',1,length(find(tmpDotColors==99)));
                end
            end
        end
        
        try
            Screen('DrawDots', curWindow, dot_show{df}, dotSize{df}, dotColor{df}, center); %% HR: assume all frames have same center
        catch
            keyboard
        end
        
        % ADDED AS (3/8/14) to deal w/ edge effects:
        if ~isnan(dotInfo.apFrameWidth)
            Screen('FrameRect', curWindow, [0 0 0], CenterRect(ScaleRect(apRect(df,:),dotInfo.apFrameScale,dotInfo.apFrameScale),apRect(df,:)),dotInfo.apFrameWidth);
        end
    end;
    
    
    % targets
    for i = showtar
        Screen('FillOval', screenInfo.curWindow, targets.colors(i,:), targets.rects(i,:));
    end
    
    
    % tell ptb to get ready while doing computations for next dots
    % presentation
    Screen('DrawingFinished',curWindow,dontclear);
    Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);
    frames = frames + 1;
    
    
    if frames == 1
        
        start_time = GetSecs;
        
    end;
    
    
    %% if delaying color, switch back to original color
    %     if dotInfo.colorDelay && (GetSecs - start_time) >= dotInfo.colorOnset
    %         dotInfo.dotColor = color;
    %         dotInfo.dotColor1 = color2;
    %
    %     end
    
    
    for df = 1 : dotInfo.numDotField,
        % update the dot position array for the next loop
        ss{df}(Lthis{df}, :) = this_s{df};
    end;
    % check for end of loop
    continue_show = continue_show - 1;
    
    %user may terminate the dots by pressing certain keyboard keys defined
    %by "keys"
    
    % this is changed so now pressing the space bar will cause a signal to
    % be sent so that the experiment will end after this trial
    
    
    
    %% GET RESPONSE INFORMATION HERE
    
    
    if ~isempty(keys) && (isnan(response_time) || dotInfo.allowContinuedKeyCheck)  % FIXED 6/13/14 morning TO STOP CHECKING AFTER RESPONSE GIVEN! (check for possible multiple responses earlier!)
        % %     if ~isempty(keys),
        [keyIsDown,secs,keyCode] = KbCheck(-1); % CHANGED 4/28/14
        
        
        %         [keyIsDown,secs,keyCode] = KbCheck;
        if keyIsDown
            % send abort signal
            if keyCode(abort)
                response{1} = find(keyCode(abort));
                sca; return;
            end
            % end trial, have response
            if any(keyCode(keys))
                tmpResponse = find(keyCode(keys));
                response{3} = tmpResponse(1);
                if ~dotInfo.showAfterRT
                    continue_show = 0;
                end
                response_time = secs-start_time;
            end;
            
        end;
    end;
    
    if ~isempty(mouse) && (isnan(response_time) || dotInfo.allowContinuedKeyCheck)
        [x,y,buttons] = GetMouse(curWindow);
        % check = 0 means exit dots, check = 1 means continue showing dots
        check = 0;
        if buttons
            % mouse was pressed, if hold is on, and we know fixation
            % position, make sure holding correct place
            if waitpress == 0
                if isfield(targets,'select')
                    check = checkPosition(x,y,h(1),k(1),r(1));
                end
            else
                % if hold is not on, and this is fixed duration, we don't
                % care if the subject touches the screen - if reaction
                % time, then touching means exit dots
                if dotInfo.trialtype(1) == 1
                    check = 1;
                end
            end
        else
            % mouse was not pressed.
            % if waiting for a mouse press, continue paradigm
            if waitpress == 1
                check = 1;
            end
        end
        if ~check
            % for fixed duration, exiting early is always an error.
            if dotInfo.trialtype(1) == 1
                response{2} = 0;
            else
                % buttons is zero if we are doing reaction time where the
                % subject has to hold during fixation, and releasing the
                % mouse signifies end of the dots, otherwise should tell
                % you the xy position. Eventually, I guess we should make
                % it so we can use two mouse buttons as the answer...
                if buttons
                    response{2} = [x y];
                    %response{2} = find(buttons(mouse));
                else
                    response{2} = 0;
                end
            end
            response_time = GetSecs;
            continue_show = 0;
        end;
    end
    
    %%%%% AS:
    if isfield(dotInfo,'gradAtt') && (dotInfo.gradAtt.T0color>0 || dotInfo.gradAtt.T0motion>0) && frames>=1 %%
        if ~dotInfo.gradAtt.Con && ((GetSecs-start_time) > dotInfo.gradAtt.T0color)
            dotInfo.dotColor = dotInfo.gradAtt.postT0col1;
            dotInfo.dotColor2 = dotInfo.gradAtt.postT0col2;
            dotInfo.curColor = dotInfo.gradAtt.postT0curColor;
            dotInfo.colorCoh = dotInfo.gradAtt.postT0cCoh;
            
            dotInfo.gradAtt.Con = 1; % color channel on
            % %             dotInfo.gradAtt.ConFramesLeft = 10;
            
            %             dotInfo.pctColor3 = 0;
            dotInfo.pctColor3dec = dotInfo.gradAtt.postT0cPctDec; % linearly decreasing by this amount by frame
        end
        if ~dotInfo.gradAtt.Mon && ((GetSecs-start_time) > dotInfo.gradAtt.T0motion)
            % Setting up motion channel
            dotInfo.coh = dotInfo.gradAtt.postT0mCoh;
            
            if dotInfo.gradAtt.useStaticMotion
                dotInfo.gradAtt.useStaticMotion = 0;
                dotInfo.pctMotionJitter = 1.0;
            end
            
            dotInfo.pctMotionJitterDec = dotInfo.gradAtt.postT0mPctDec; % linearly decreasing by this amount by frame
            %             dotInfo.speed = dotInfo.gradAtt.postT0speed;
            dotInfo.speedDec = -dotInfo.gradAtt.postT0mPctDec*(dotInfo.gradAtt.postT0speed-dotInfo.gradAtt.preT0speed);
            dotInfo.speed = min(dotInfo.gradAtt.postT0speed,dotInfo.speed+dotInfo.speedDec);
            
            coh   	= dotInfo.coh/1000;	%  % dotInfo.coh is specified on 0... (because
            dotInfo.dir = dotInfo.gradAtt.postT0mDir;
            
            for df = 1 : dotInfo.numDotField,
                % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
                %    	 deg/sec     * Ap-unit/deg  * sec/jump   =   unit/jump
                dxdy{df} 	= repmat((dotInfo.speed(df)/10) * (10/apD(df)) * (3/screenInfo.monRefresh) ...
                    * [cos(pi*dotInfo.dir(df)/180.0) -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);
                
                % % %                 % ARRAYS, INDICES for loop
                % % %                 ss{df}		= rand(ndots(df)*3, 2); % array of dot positions raw [xposition yposition]
                % % %                 % divide dots into three sets...
                % % %                 Ls{df}      = cumsum(ones(ndots(df),3))+repmat([0 ndots(df) ndots(df)*2], ndots(df), 1);
                % % %                 loopi(df)   = 1; 	% loops through the three sets of dots
            end
            
            dotInfo.gradAtt.Mon = 1; % motion channel on
            
            % %             dotInfo.gradAtt.MonFramesLeft = 10;
        elseif dotInfo.gradAtt.Mon && (dotInfo.pctMotionJitter~=0 || dotInfo.speed<dotInfo.gradAtt.postT0speed)
            dotInfo.speed = min(dotInfo.gradAtt.postT0speed,dotInfo.speed+dotInfo.speedDec);
            
            for df = 1 : dotInfo.numDotField,
                % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
                %    	 deg/sec     * Ap-unit/deg  * sec/jump   =   unit/jump
                dxdy{df} 	= repmat((dotInfo.speed(df)/10) * (10/apD(df)) * (3/screenInfo.monRefresh) ...
                    * [cos(pi*dotInfo.dir(df)/180.0) -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);
                
                % % %                 % ARRAYS, INDICES for loop
                % % %                 ss{df}		= rand(ndots(df)*3, 2); % array of dot positions raw [xposition yposition]
                % % %                 % divide dots into three sets...
                % % %                 Ls{df}      = cumsum(ones(ndots(df),3))+repmat([0 ndots(df) ndots(df)*2], ndots(df), 1);
                % % %                 loopi(df)   = 1; 	% loops through the three sets of dots
            end
        end
    end
    if dotInfo.pctColor3dec~=0
        dotInfo.pctColor3 = max(0,dotInfo.pctColor3+dotInfo.pctColor3dec);
    end
    if dotInfo.pctMotionJitterDec~=0
        dotInfo.pctMotionJitter = max(0,dotInfo.pctMotionJitter+dotInfo.pctMotionJitterDec);
    end
end

%%
if dotInfo.isFrozArray
    start_time = GetSecs;
    df = 1;
    % CORRECTED THIS TO BE SAME GRAY AS MOTION ON 5/7/14
    fixedGray = [200 200 200];  % indexed as 0
    % %     fixedGray = [137 137 137];  % indexed as 0
    fixedCols = {[5 137 255],[255 65 2], [2 159 50],...
        [142	142	0],[241	0	241],[0	153	153],...
        [200	112	112],[100	149	100],[121	121	255],...
        [100	145	145],[197	100	197],[140	139	100],...
        [255	62	62],[75	154	75],[132	132	190],...
        }; % indexed by Col #
    
    %%% DOT SETUP %%%%%%%%%
    Lthis{df}  = Ls{df}(:,loopi(df));  % Lthis now has the dot positions from 3 frames ago, which is what is then
    this_s{df} = ss{df}(Lthis{df},:); % this is a matrix of random #s - starting positions for dots not moving coherently
    N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
    if sum(N) > 0
        xdir = sin(pi*dotInfo.dir(df)/180.0);
        ydir = cos(pi*dotInfo.dir(df)/180.0);
        % flip a weighted coin to see which edge to put the replaced
        % dots
        if rand < abs(xdir)/(abs(xdir) + abs(ydir))
            this_s{df}(find(N==1),:) = [rand(sum(N),1) (xdir > 0)*ones(sum(N),1)];
        else
            this_s{df}(find(N==1),:) = [(ydir < 0)*ones(sum(N),1) rand(sum(N),1)];
        end
    end
    this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
    dot_show{df} = (this_x{df} - d_ppd(df)/2)';
    
    % % %     tmpDotColors = round(rand(1,size(dot_show{df},2)));
    
    if dotInfo.curColor==0  % ASSUMING GRAY - UNLIKE ABOVE!!
        tmpDotColors = zeros(1,size(dot_show{df},2)); % dot color 1 = 0
    else % ASSUMING RAND DISTRIBUTION IF CURCOLOR>0
        RandStream.setDefaultStream(RandStream('mt19937ar','Seed',sum(100*clock))); %reset the random number generator
        tmpDotColors = randsample(1:length(fixedCols),size(dot_show{df},2),true);
    end
    
    dotArraySize = length(tmpDotColors);
    % Splitting colors evenly:
    % % %     tmpDotColors(1:(round(0.5*length(tmpDotColors)))) = 0; % dot color 1 = 0
    tmpDotColors = tmpDotColors(randperm(length(tmpDotColors)));
    dotColor{df} = ones(3,size(dot_show{df},2));
    
    tmpUniqueCols = unique(tmpDotColors);
    for uqii = 1:length(tmpUniqueCols)
        if tmpUniqueCols(uqii)==0  % GRAY
            dotColor{df}(:,tmpDotColors==0) = ...
                repmat(fixedGray',1,length(find(tmpDotColors==0)));
        else  % COLOR
            dotColor{df}(:,tmpDotColors==tmpUniqueCols(uqii)) = ...
                repmat(fixedCols{tmpUniqueCols(uqii)}',1,length(find(tmpDotColors==tmpUniqueCols(uqii))));
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);
    Screen('FillRect', curWindow, [0 0 0 255]);
    Screen('FillRect', curWindow, [0 0 0 0], apRectBigger(df,:));
    Screen('FillOval', curWindow, [0 0 0 255], apRect(df,:));
    Screen('BlendFunction', curWindow, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    Screen('DrawDots', curWindow, dot_show{df}, dotSize{df}, dotColor{df}, center(df,:));
    
    if screenInfo.showAttendCues
        Screen(screenInfo.curWindow,'TextSize',screenInfo.cueTextSize);
        % ADJUST COLOR HERE AND ABOVE:
        %         Screen(screenInfo.curWindow,'DrawText',dotInfo.curAttendCue,screenInfo.center(1),screenInfo.center(2), [255,255,255]);%,dotInfo.dotColor);
        DrawFormattedText(curWindow, '+', 'center', 'center', [255,255,255]);
        
    end
    
    Screen('FrameRect', curWindow, [0 0 0], CenterRect(ScaleRect(apRect(df,:),dotInfo.apFrameScale,dotInfo.apFrameScale),apRect(df,:)),dotInfo.apFrameWidth);
    Screen('DrawingFinished',curWindow,dontclear);
    Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);
    %     dontclear = 1;
end

% present last frame of dots
Screen('Flip', curWindow,0,dontclear);
% if dotInfo.isFrozArray
%     WaitSecs(dotInfo.maxDotTime-(GetSecs-dotsX_callStart));
% end
% erase last dots, but leave up fixation and targets (if targets are up)
% make sure the fixation still on
if ~isempty(showtar)
    showTargets(screenInfo, targets, showtar);
end
%showtar
end_time = GetSecs;
if ~dotInfo.isFrozArray
    Priority(0);
end

end


function tarRects = createTRect(target_array, screenInfo)
% function tarRects = getTRect(target_array, screenInfo)
%	Gets the display rect for the list of targets
%	Argument target_array is nx3, where the columns are
%		x_position y_position diameter

% 1/17/06  RK modified it for Windows operating system
% July 2006 MKMK modified it for OSX
% do no error checking -- assume it's been done already

xy = target_array(:,1:2);
diameter = target_array(:,3);

center = repmat(screenInfo.center, size(xy(:,1)));

% ppd is off by a factor of 10 so that we don't send any fractions to rex
ppd = screenInfo.ppd/10;

% change the xy coordinates to pixels (y is inverted - pos on bottom, neg.
% on top
tar_xy = [center(:,1)+xy(:,1)*ppd center(:,2)-xy(:,2)*ppd];

% change the diameter to pixels, make it same size as tar_xy so we can add
% them
diam = repmat(diameter, size(tar_xy(1,:))) * ppd;

% now need to change from center and diameter to the corners of a box that
% would enclose the circle for use with Screen('FillOval')
tarRects = [tar_xy-diam/2 tar_xy+diam/2];
end













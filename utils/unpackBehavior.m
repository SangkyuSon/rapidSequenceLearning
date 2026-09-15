function [event,repetition] = unpackBehavior(trialVariables)
% unpackBehavior  Behavioral codes from the raw trial variables of one session.
%
%   event      : 1 x nTrial cell. Per trial, the sequence of uncovering events.
%                1 = incorrect press, 2 = correct press, above 2 = non-press.
%   repetition : 1 x nTrial double. Position of the trial within its block,
%                restarting at 1 whenever a new sequence begins.

trialData   = squeeze(struct2cell(trialVariables));
trialFields = fieldnames(trialVariables);

wasPressed = cellfun(@(x1) transferVal(x1,nan,0),trialData(strcmp(trialFields,'pressed_to_uncover'),:),'un',0);
wasCorrect = cellfun(@(x1) transferVal(x1,nan,0),trialData(strcmp(trialFields,'correct_uncover'),:),'un',0);
pressCode  = cellfun(@(x1,x2) x1+x2,wasPressed,wasCorrect,'un',0);

event = cellfun(@(x1) labelNonPressEvents(x1),pressCode,'un',0);

opensNewBlock = cell2mat(trialData(strcmp(trialFields,'first_trial'),:));
blockStart    = [find(opensNewBlock),length(opensNewBlock)+1];

repetition = zeros(size(opensNewBlock));
for b = 1:length(blockStart)-1
    repetition(blockStart(b):blockStart(b+1)-1) = (blockStart(b):blockStart(b+1)-1)-blockStart(b)+1;
end

    function labeled = labelNonPressEvents(codes)
        % events between two presses carry the following press code, offset by 2
        labeled    = codes;
        pressIndex = [0,find(codes)];
        for p = 1:length(pressIndex)-1
            labeled(pressIndex(p)+1:pressIndex(p+1)-1) = labeled(pressIndex(p+1))+2;
        end
    end

end

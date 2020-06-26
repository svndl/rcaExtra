function [filteredSignal] = FilterEpoch(rawSignal,operation, harmonic, plotflag)
%% This function takes the raw epoch EEG signal and applies a filter to it, based on the frequency components to remove or keep provided in the input variables.
%% Note: this is not directly related to filtering, in processing pipeline, the artifact removal should be done prior to using FilterEpoch().
%% Make sure entire epochs submitted for filtering are artifacf-free. Also note, the duration of "quality assurance epochs" (QA epochs), exported by xDiva along raw EEGs, is the duration of one stimulus cycle, and, in general, may differ from the duration of "analysis epochs" in custom Matlab code.
%% xDiva uses a simple rule for determining whether EEG epochs are "good", i.e. artifact free – a raw EEG epoch is "good" if it does not contain any "bad" QA (sub)epochs, otherwise the entire EEG epoch is "bad".

%% INPUT ARGS (REQUIRED)
%   rawSignal :input raw signal (columm vector for single channel or multichanel
%   where channels are columns)
%
%   operation : "remove" or "keep" (keeps or removes the frequency and its harmonics)
%   harmonic : frequency "INDEX" of the first epoch harmonic of interest, number of its cycles per epoch. (components to filter (remove/keep)
%   plotflag = 0/1  (1 : plot original and fitered  signal waveforms)

%% OUTPUT ARGS
%   filterdSignal - (vector- signal channel or multichanel
%   where channels are columns)

%% USAGE:
%   [filteredSignal] = FilterEpoch(rawSignal,'keep', 6, 1)

%%%%% TODO:
%   selection: 'all', 'odd', 'even' (remove/keep all harmonics, or only odd/even harmonics)
%%%%%%%%%%%%%%%%%ive = false;

%%% check if input data in single or multi-channel
%%

if size(rawSignal,1) ==1;
    display('making the original signal a column vector');
    rawSignal =rawSignal';
end


filteredSignal= [];

%% perform filtering across all channels:
for chan=1:size(rawSignal,2)
    
    origwave= rawSignal(:,chan);
    %% now perform fourier tranform
    FFT_origwave = fft(origwave); %% fourier
    
    if strcmp(operation, 'remove')
        
        FFT_origwave(harmonic:harmonic-1:end)=0; % remove X Hz and its harmonics
        signal_cleared = ifft(FFT_origwave); %% inverse fourier
        filteredSignal(:,chan)=real(signal_cleared);
        
        if plotflag==1
            figure; subplot(1,2,1); hold; title('original wave'); plot(origwave); hold off;
            subplot(1,2,2);  hold; title('filtered wave'); plot(filteredSignal(:,chan)); hold off;
        end
        
    elseif strcmp(operation, 'keep')
        temp_FFT_origwave =  zeros(1,length(origwave));
        temp_FFT_origwave(harmonic:harmonic-1:end) = FFT_origwave(harmonic:harmonic-1:end); % keep X Hz and its harmonics remove everthing else.
        signal_cleared = ifft(temp_FFT_origwave); %% inverse fourier
        filteredSignal(:,chan)=real(signal_cleared);
        if plotflag==1
            figure; subplot(1,2,1); hold; title('original wave'); plot(origwave); hold off;
            subplot(1,2,2);  hold; title('filtered wave'); plot(filteredSignal(:,chan));  hold off;
        end
    end
    
end





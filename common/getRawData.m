function varargout = getRawData(info)
    
    subtype_sep = '/'; 
    [datatype, subtype] = strtok(info.domain, subtype_sep);
    if (~isempty(subtype))
        subtype = subtype(2:end); % remove '/'
    end
    if(~info.useSpecialDataLoader) 
        switch datatype
            case 'freq'
                [subjList, sensorData, cellNoiseData1, cellNoiseData2, infoOut]...
                    = readRawEEG_freq(info);
                varargout{1} = subjList;                
                varargout{2} = sensorData;
                varargout{3} = cellNoiseData1;
                varargout{4} = cellNoiseData2;
                varargout{5} = infoOut;
            case 'time'
                switch subtype
                    case 'axx'
                        sensorData = readAxxEEG(info);                
                    otherwise
                        [subjList, sensorData] = readRawEEG_time(info);
                end
                varargout{1} = subjList;
                varargout{2} = sensorData;  
        end
    else
        %% special loader 
        fName = strcat('getRawData_', info.experiment);        
        [varargout{1:nargout}] = feval(fName, info);
    end
end
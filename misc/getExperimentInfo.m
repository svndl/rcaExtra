function dataInfo = getExperimentInfo(experiment)
    switch experiment
        case 'HexagonsSquares'
            dataInfo.frequency = 3;
            dataInfo.conditionLabels = {'Hex 28 amin ON', 'Hex 28 amin OFF', ...
                'Hex 40 amin ON', 'Hex 40 amin OFF', ...
                'Hex 56 amin ON', 'Hex 56 amin OFF', ...
                'Hex 80 amin ON', 'Hex 80 amin OFF', ...
                'Squares ON', 'Squares OFF'};
            dataInfo.specialLoader = 0;
            dataInfo.subgroupsLabels = {'Hex 28 amin', 'Hex 40 amin', 'Hex 56 amin', 'Hex 80 amin', 'Squares'};
            dataInfo.subcndLabels = {'ON', 'OFF'};
            dataInfo.Channels = 75;
            dataInfo.Freqs = {'F1'};                        
            dataInfo.nBins = 10;
            dataInfo.FreqMultipliers = 4;
        case 'UpperVsLower'
            dataInfo.frequency = 2.723;
            dataInfo.conditionLabels = {'Upper Square ON', 'Upper Square OFF', ...
                'Lower Square ON', 'Lower Square OFF', ...
                'Upper Full ON', 'Upper Full OFF', ...
                'Lower Full ON', 'Lower Full OFF'};
            dataInfo.subgroupsLabels = {'Upper Square', 'Lower Square', 'Upper Full', 'Lower Full'};
            dataInfo.subcndLabels = {'ON', 'OFF'};
            dataInfo.nBins = 10;
            dataInfo.FreqMultipliers = 4;            
            dataInfo.specialLoader = 0;
            dataInfo.Channels = [75, 81];
            dataInfo.Freqs = {'F1'};            
        case 'FullField'
            dataInfo.frequency = 2.723;            
            dataInfo.conditionLabels = {'ON', 'OFF'};
            dataInfo.specialLoader = 1;
            dataInfo.subgroupsLabels = {'FullField'};
            dataInfo.subcndLabels = {'ON', 'OFF'};
            dataInfo.nBins = 8; % 5 for controls and patients?
            dataInfo.FreqMultipliers = 4;
            dataInfo.Channels = 76;
            dataInfo.Freqs = {'F1'};            
        case '2F'
            dataInfo.frequency = [3, 3.75];
            dataInfo.subcndLabels = {'ON', 'OFF'}; 
            dataInfo.subgroupsLabels = {'Upper 3hz', 'Upper 3.75hz', 'Lower 3hz', 'Lower 3.75hz'};            
            dataInfo.specialLoader = 1;
            dataInfo.conditionLabels = {'Upper 3hz ON', 'Upper 3hz OFF', ...
                'Upper 3.75hz ON', 'Upper 3.75hz OFF', ...
                'Lower 3hz ON', 'Lower 3hz OFF', ...
                'Lower 3.75hz ON', 'Lower 3.75hz OFF'};
            dataInfo.FreqMultipliers = 4;
            dataInfo.nBins = 10;
            dataInfo.Freqs = {'F1', 'F2'};
            %convention channel(1) frequency(1) and channel(2) frequency(2)
            dataInfo.Channels = [75, 81];       
        case '1f2f'          
            dataInfo.frequency = [2.73, 3, 3.75];
            dataInfo.subcndLabels = {'ON', 'OFF'}; 
            dataInfo.subgroupsLabels = {'2.73hz', 'Upper 3.75hz', 'Lower 3hz'};            
            dataInfo.specialLoader = 1;
            dataInfo.conditionLabels = {'2.73hz ON', '2.73hz OFF', ...
                '2.73hz ON', '2.73hz OFF', ...
                'Upper 3hz/Lower 3.75hz ON', 'Upper 3hz/Lower 3.75hz OFF', ...
                'Upper 375hz/Lower 3hz ON', 'Upper 3.75hz/Lower 3hz OFF', ...
                'Upper 3hz/Lower 3.75hz ON', 'Upper 3hz/Lower 3.75hz OFF', ...
                'Upper 375hz/Lower 3hz ON', 'Upper 3.75hz/Lower 3hz OFF', ...                
                };
            dataInfo.FreqMultipliers = 4;
            dataInfo.nBins = 10;
            dataInfo.Freqs = {'F1', 'F2'};
            %convention channel(1) frequency(1) and channel(2) frequency(2)
            dataInfo.Channels = [75, 81];         
        case '2FContrast'
            dataInfo.frequency = [3.75, 3];
            dataInfo.subcndLabels = {'ON', 'OFF'};
            dataInfo.subgroupsLabels = {'Upper 5%', 'Upper 10%', 'Upper 20%', 'Upper 40%', 'Upper 80%', ...
                'Lower 5%', 'Lower 10%', 'Lower 20%', 'Lower 40%', 'Lower 80%'};
            dataInfo.specialLoader = 1;
            dataInfo.conditionLabels = {'Upper 5% ON', 'Upper 5% OFF', ...
                'Upper 10 ON%', 'Upper 10% OFF', ...
                'Upper 20% ON', 'Upper 20% OFF', ...
                'Upper 40% ON', 'Upper 40% ON', ...
                'Upper 80% ON', 'Upper 80% OFF', ...
                'Lower 5% ON', 'Lower_5% OFF', ...
                'Lower 10 ON%', 'Lower 10% OFF', ...
                'Lower 20% ON', 'Lower 20% OFF', ...
                'Lower 40% ON', 'Lower 40% ON', ...
                'Lower 80% ON', 'Lower 80% OFF'};
            dataInfo.Channels = [75, 80];
            dataInfo.FreqMultipliers = 4;
            dataInfo.nBins = 10;
            dataInfo.Freqs = {'F1', 'F2'};
        case '2FSizes'
            dataInfo.frequency = [3.75, 3];
            dataInfo.subcndLabels = {'ON', 'OFF'};
            dataInfo.conditionLabels = {'Hex 28 amin ON', 'Hex 28 amin OFF', ...
                'Hex 40 amin ON', 'Hex 40 amin OFF', ...
                'Hex 56 amin ON', 'Hex 56 amin OFF', ...
                'Hex 80 amin ON', 'Hex 80 amin OFF'};
            dataInfo.specialLoader = 0;
            dataInfo.subgroupsLabels = {'Hex 28 amin', 'Hex 40 amin', 'Hex 56 amin', 'Hex 80 amin'};
            dataInfo.Channels = [75, 81];
            dataInfo.FreqMultipliers = 4;
            dataInfo.nBins = 10;
            dataInfo.Freqs = {'F1', 'F2'};
    end
end
           
    
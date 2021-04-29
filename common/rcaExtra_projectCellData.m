function dataOut = rcaExtra_projectCellData(dataIn, W)
% Projects data data_In using weights W
% Alexandra Yakovleva, Stanford University 2012-2021.

    %% project using W
    dataOut = cellfun(@(x) rcaExtra_project3DMatrix(x, W), dataIn, 'uni', false);
end
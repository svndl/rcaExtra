function rcaExtra_displayError(errStruct)
    fprintf('Failed at : %s ...\n', errStruct.message);
    stackDepth = size(errStruct.stack, 1);
    for s = 1:stackDepth
        fprintf('Function %s ... line %d \n', errStruct.stack(s).name, errStruct.stack(s).line);
    end
end
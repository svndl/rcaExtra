function headerTable = rcaExtra_getXDivaTextHeaderTable

    headers = {
            'iSess'         '%s\t'      0   's' %1 
            'iCond'         '%f\t'      1   'f' %2
            'iTrial'        '%f\t'      1   'f' %3
            'iCh'           '%s\t'      1   's' %4
            'iFr'           '%f\t'      1   'f' %5
            'AF'            '%f\t'      1   'f' %6
            'xF1'           '%f\t'      1   'f' %7
            'xF2'           '%f\t'      1   'f' %8
            'Harm'          '%s\t'      2   's' %9
            'FK_Cond'       '%f\t'      1   'f' %10
            'iBin'          '%f\t'      1   'f' %11
            'SweepVal'      '%f\t'      1   'f' %12
            'Sr'            '%f\t'      1   'f' %13
            'Si'            '%f\t'      1   'f' %14
            'N1r'           '%f\t'      1   'f' %15
            'N1i'           '%f\t'      1   'f' %16
            'N2r'           '%f\t'      1   'f' %17
            'N2i'           '%f\t'      1   'f' %18
            'Signal'        '%f\t'      1   'f' %19
            'Phase'         '%f\t'      1   'f' %20
            'Noise'         '%f\t'      1   'f' %21
            'StdErr'        '%f\t'      1   'f' %22
            'PVal'          '%f\t'      1   'f' %23
            'SNR'           '%f\t'     2    'f' %24
            'LSB'           '%f\t'     2    'f' %25
            'RSB'           '%f\t'     2    'f' %26
            'UserSc'        '%s\t'     2    's' %27
            'Thresh'        '%f\t'     2    'f' %28
            'ThrBin'        '%f\t'     2    'f' %29
            'Slope'         '%f\t'     2    'f' %30
            'ThrInRange'    '%s\t'     2    's' %31
            'MaxSNR'        '%f\t'     2    'f'}; %32
    
        %code for double is f, for string is s
        nElems = 1:size(headers, 1);
        headerTable = table(nElems', headers(:, 4), 'RowNames', headers(:, 1));   
end
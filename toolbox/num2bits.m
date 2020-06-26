function rB = num2bits( aV, aN )
    tV = aV(:); % Make sure v is a row vector.
    tNV = length( tV ); % number of numbers to convert
    rB = zeros( tNV, aN );
    tP = aN - 1;
    rB( :, 1 ) = mod( tV, ( 2 ^ aN ) );
    for iP = 1:( aN - 1 )
        rB( :, iP+1 ) = mod( rB( :, iP ), ( 2 ^ tP ) );
        rB( :, iP ) = floor( rB( :, iP ) / ( 2 ^ tP ) );
        tP = tP - 1;
    end
    rB( :, end ) = floor( rB( :, end ) / ( 2 ^ tP ) );
    rB ( rB == 0 ) = -1;
end
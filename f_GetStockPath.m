function vec_S = f_GetStockPath( S0 , Sigma , r , T , m )

% Calculate parameter
dT = T / m ;     % Time in years per period.
u = exp( Sigma * sqrt(dT) );
d = 1 / u;
p = ( exp(r * dT) - d ) / ( u - d );
q =  1 - p;

% Initialize the output variable: vec_S
vec_S = zeros( m + 1 , 1 ); % The vector to store prices
vec_S(1) = S0;
% Main loop
for i = 2 : m + 1
    if rand < p
        vec_S(i) = vec_S(i-1) * u;  % Stock price go up
    else
        vec_S(i) = vec_S(i-1) * d;  % Stock price go down
    end  % if
end  % i
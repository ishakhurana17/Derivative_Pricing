% This program calculates option prices using Monte Carlo simulation
close all; clear all; clc; dbstop if error

% Input Variables
% General variables for all options
S0 = 100;       % Stock price now
Sigma = 0.2;    % Annual standard deviation of the stock price
r = 0.02;       % Riskfree rate (Annual)
T = 2;          % Time to maturity in years
m = 1000;          % Number of time periods
N = 10000;      % Number of price paths in the simulation
% Option specific variables
S_Option_Model = 1; % 1 for European Call/Put; 2 for Lookback; 
% 3 for Barrier options; 4 for Asian options; 5 for customized option
X = 100;        % Exercise price
Is_Call = -1;    % 1 for call; -1 for put;
B = 80;         % Barrier for barrier options
Is_Knock_In = 1;% Barrier options: 1 for Knock_In; 0 for Knock_Out

% Initialization before the simulation loop
vec_Payoff = zeros( N , 1 ); % Vector to store simulated payoffs.

vec_max = zeros(N,1);
vec_min = zeros(N,1);
vec_ST = zeros(N,1);
vec_STby2 = zeros(N,1);

% Main loop
for i = 1 : N
    % Step 1: Generate one price path randomly.
    vec_S = f_GetStockPath( S0 , Sigma , r , T , m ); % vec_S has m + 1 elements
    % Step 2: Calculate option payoff based on this price path.
    switch S_Option_Model
        case 1  % European Call/Put
            vec_Payoff(i) = f_Payoff_European( vec_S , X , Is_Call,m );
        case 2  % Lookback
            vec_Payoff(i) = f_Payoff_Lookback( vec_S , Is_Call , m);
        case 3  % Barrier
            vec_Payoff(i) = f_Payoff_Barrier( vec_S , X , B , ...
                            Is_Call , Is_Knock_In );
        case 4  % Asian
            vec_Payoff(i) = f_Payoff_Asian( vec_S , X , Is_Call );
        case 5  % Other options, or customized option
            vec_Payoff(i) = f_Payoff_Custom( vec_S , X , Is_Call );
    end   % switch
vec_max(i) = max(vec_S);
vec_min(i) = min(vec_S);
vec_ST(i) = vec_S(m+1);
vec_STby2(i) = vec_S(m/2+1);
end   % i

% Step 3: Calculate the option price based on simulated payoffs
Option_Price = mean(vec_Payoff) * exp( -r * T )
Max = mean(vec_max)
Min = mean(vec_min)
ST  = mean(vec_ST)
STby2 = mean(vec_STby2)


% European Call Put option
function [op_val] =  f_Payoff_European( vec_S , X , Is_Call ,m)
op_val = max(Is_Call*(vec_S(m+1)-X),0);
end

%Lookback Option
function [op_val] =  f_Payoff_Lookback( vec_S , Is_Call , m)
if Is_Call > 0
    LookbackStockVal = min(vec_S);
else
    LookbackStockVal = max(vec_S);
end % if Is_Call
op_val = max(Is_Call*(vec_S(m+1)-LookbackStockVal),0);
end

%Barrier option
function [op_val] = f_Payoff_Barrier( vec_S , X , B , Is_Call ,Is_Knock_In)
% Make the option Dead if it is Knock In and Active if Knock Out
if Is_Knock_In 
    Is_Active = 0 ;
else 
    Is_Active = 1 ;
end

% If the Barrier is between the max and min of stock price switch the
% Active parameter

if min(vec_S) < B
    if max(vec_S) > B
        Is_Active = 1 - Is_Active;
    end
end
% Calculate the call 
op_val = max(Is_Active*Is_Call*(vec_S(end)-X),0);
end

% Asian option
function [op_val] =  f_Payoff_Asian( vec_S , X , Is_Call )
op_val = max(Is_Call*(mean(vec_S)-X),0);
end


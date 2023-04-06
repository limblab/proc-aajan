% @brief computes pseudo R-squared measure for Poisson regression models
% from real and fitted data according [1, page 255, first formula]
% @author Valentina Unakafova (UnakafovaValentina@gmail.com)
% @date 22.08.2018
%
% INPUT
% realData      - observed values of dependent variable
% estimatedData - predicted values
% lambda        - mean value (can be mean value over dataset or over realData)
% OUTPUT 
% pR2 - value of pseudo R-squared measure
%
% EXAMPLE OF USE
% % download 'arsdata_1950_2010.xls' at 
% http://www.maths.lth.se/matstat/kurser/fmsf60/_Labfiles/arsdata_1950_2010.xls
%{
  data = xlsread( 'arsdata_1950_2010.xls' ); % read data
  startPoint = 26;
  traffic = struct( 'year', data( startPoint:end, 1 ), 'killed', ...
    data( startPoint:end, 2 ), 'cars', data( startPoint:end, 5 ), ...
    'petrol', data( startPoint:end, 6 ) ); 
  y = traffic.killed; 
  x = cell( 1, 3 ); % covariates or predictors
  estCoeff   = cell( 1, 3 ); % estimated coefficients of model fit
  yEstimated = cell( 1, 3 ); 
  pR2value   = zeros( 1, 3 ); 
  x{ 1 } = traffic.year - mean( traffic.year ); 
  x{ 2 } = [ x{ 1 }, traffic.cars - mean( traffic.cars ) ]; 
  x{ 3 } = [ x{ 2 }, traffic.petrol - mean( traffic.petrol ) ]; 
  for iCovariate = 1:3
    % leave-one-out cross-validation
    for iPoint = 1:length( y )
      trainingSet = [ 1:iPoint - 1 iPoint+1:length( y ) ];
      estCoeff{ iCovariate } = glmfit( x{ iCovariate }( trainingSet, : ), ...
                              y( trainingSet ), 'poisson', 'link', 'log' ); 
      yEstimated{ iCovariate }( iPoint ) = glmval( estCoeff{ iCovariate }, ...
                                     x{ iCovariate }( iPoint, : ), 'log' ); 
    end
    pR2value( iCovariate ) = pseudoR2( y', yEstimated{ iCovariate }, mean( y ) ); 
  end 

  % plot results
  fontSize   = 20;
  figure; 
  plot( traffic.year, traffic.killed, '-', 'LineWidth', 4 ); hold on; 
  for iCovariate = 1:3
    plot( traffic.year, yEstimated{ iCovariate }, 'o', 'LineWidth', 4, ...
                                                'markerSize', 8 ); 
  end
  xlabel( 'Year', 'FontSize', fontSize ); 
  ylabel( 'Number of people killed in accidients', 'FontSize', fontSize ); 
  legendHandle = legend( 'Real', ... 
    [ 'Estimated from year, $pR^2$ = ' num2str( pR2value( 1 ), '%.3f' ) ], ... 
    [ 'Estimated from year and cars, $pR^2$ = ' num2str( pR2value( 2 ), '%.3f' ) ], ... 
    [ 'Estimated from year, cars and petrol, $pR^2$ = ' num2str( pR2value( 3 ), '%.3f' ) ] );
  legendHandle.FontSize = fontSize;
  set( legendHandle, 'Interpreter', 'Latex' );
  set( gca, 'FontSize', fontSize );
%}
% REFERENCES
% [1] Heinzl, H. and Mittlboeck, M., 2003. 
% Pseudo R-squared measures for Poisson regression models with over-or underdispersion. 
% Computational statistics & data analysis, 44(1-2), pp.253-271.
% [2] http://www.math.chalmers.se/Stat/Grundutb/CTH/mve300/1112/files/lab4/lab4.pdf

function pR2 = pseudoR2( realData, estimatedData, lambda )  
  EPS = 0.0000000001;
  nPoints1 = size( realData );
  nPoints2 = size( estimatedData );
  if ( nPoints1( 1 ) > nPoints1( 2 ) || nPoints2( 1 ) > nPoints2( 2 ) )
    error( 'Input data should be 1-dimensional vectors' );
  end
  if ( length( realData ) ~= length( estimatedData ) )
    error( 'Lengths of input real and estimated data are not the same' );
  else
    nPoints  = length( realData );
    if ( lambda == 0 )
      meanData = zeros( 1, nPoints ) + EPS;
    else
      meanData = zeros( 1, nPoints ) + lambda;
    end
  end
  estimatedData( estimatedData == 0 ) = EPS;
  division1 = realData./estimatedData;
  division2 = realData./meanData;
  division1( division1 == 0 ) = EPS;
  division2( division2 == 0 ) = EPS;
  sum1 = sum( realData.*log( division1 ) - ( realData - estimatedData ) );
  sum2 = sum( realData.*log( division2 ) - ( realData - meanData ) );
  if ( sum2 == 0 )
    sum2 = EPS;
  end
  pR2 = 1 - sum1/sum2;

  
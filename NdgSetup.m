fprintf('\n----------------------------------------------------------\n')
fprintf('%s:: Setup environment path.\n', mfilename);
addpath( genpath( 'lib' ) );
addpath( genpath( 'NdgCell' ) );
addpath( genpath( 'NdgMesh') );
addpath( genpath( 'NdgEdge') );
addpath( genpath( 'NdgPhys') );
addpath( genpath( 'NdgNetCDF') );
addpath( genpath( 'NdgLimiter') );
addpath( genpath( 'Utilities') );
addpath( genpath( 'Application') );
fprintf('\n----------------------------------------------------------\n')

fprintf('%s:: Compile mex files.\n', mfilename);
NdgConfigure(4)
fprintf('\n----------------------------------------------------------\n')
fprintf('%s:: Finish all the setup process.\n\n', mfilename);
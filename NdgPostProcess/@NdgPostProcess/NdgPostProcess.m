classdef NdgPostProcess < handle
    
    properties
        %> number of mesh
        Nmesh
        %> mesh objects
        meshUnion
        %> output NetCDF file name
        outputFile
        %> number of variable field
        Nvar
        %> number of output step
        Nt
        %> output time 
        time 
    end
    
    methods
        function obj = NdgPostProcess( meshUnion, casename )
            [ obj.Nmesh ] = numel( meshUnion );
            [ obj.meshUnion ] = meshUnion;
            [ obj.outputFile ] = cell( obj.Nmesh, 1 );
            
            for n = 1:obj.Nmesh
                [ obj.outputFile{n} ] = [ casename, '.', num2str(n), '-', ...
                    num2str(obj.Nmesh), '.nc'];
            end
            
            [ obj.Nt ] = accessOutputStepNumber( obj );
            [ obj.Nvar ] = accessOutputVarNumber( obj );
        end
        
        %======================================================================
        %> \brief Brief description of the function
        %>
        %> More detailed description.
        %>
        %> @param arg1 First argument
        %> @param arg2 Second argument
        %>
        %> @retval out1 return value for the first output variable
        %> @retval out2 return value for the second output variable
        %======================================================================
        %> This function is part of the NDGOM software.
        %> @author li12242, Tianjin University, li12242@tju.edu.cn
        %======================================================================
        function drawResult( obj, fieldId, fphysField )
            varId = fieldId;
            for t = 1:obj.Nt
                field = obj.accessOutputResultAtStepNum( t );
                for m = 1:obj.Nmesh
                    obj.meshUnion(m).draw( field{m}(:,:,varId) + fphysField );
                end
                drawnow;
            end
        end
        
        [ mass ] = checkMassVolume( obj, varId )
        
        [ err ] = evaluateNormErr1( obj, fphys, fext );
        [ err ] = evaluateNormErr2( obj, fphys, fext );
        [ err ] = evaluateNormErrInf( obj, fphys, fext );
        
        [ fg ] = interpolateOutputStepResultToGaugePoint( obj, xg, yg, zg, outputStep );
        [ fg ] = interpolateOutputResultToGaugePoint( obj, xg, yg, zg );
        [ fg ] = interpolatePhysFieldToGaugePoint( obj, fphys, xg, yg, zg );
        
        [ Noutput ] = accessOutputStepNumber( obj )
        [ fphys ] = accessOutputResultAtStepNum( obj, stepId )
        [ Nvar ] = accessOutputVarNumber( obj )
    end
    
end


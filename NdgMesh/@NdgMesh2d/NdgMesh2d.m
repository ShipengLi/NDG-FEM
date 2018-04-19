%> Create the 2d mesh object. The object is inherited from the mesh
%> object and has special treatment for the 2d elements (triangle and
%> quadrilateral). The mesh object contains only one type of elements,
%> and allocate multiple choices to create the object. The input
%> methods include
classdef NdgMesh2d < NdgMesh
    properties(Constant)
        type = NdgMeshType.TwoDim
    end
    
    properties( Hidden=true )
        point_h
    end
    
    methods(Hidden, Access=protected)
        function [ edge ] = makeConnectNdgEdge( obj, mesh1, mid0, mid1 )
            edge = NdgEdge2d( obj, mesh1, mid0, mid1 );
        end
        
        function [ rx, ry, rz, sx, sy, sz, tx, ty, tz, J ] = assembleJacobiFactor(obj)
            xr = obj.cell.Dr*obj.x; xs = obj.cell.Ds*obj.x;
            yr = obj.cell.Dr*obj.y; ys = obj.cell.Ds*obj.y;
            J = -xs.*yr + xr.*ys;
            
            rx = ys./J; sx =-yr./J;
            ry =-xs./J; sy = xr./J;
            
            tx = zeros(size(rx));
            ty = zeros(size(ry));
            rz = zeros(size(rx));
            sz = zeros(size(rx));
            tz = zeros(size(rx));
        end
        
        function [nx, ny, nz, Js] = assembleFacialJaobiFactor( obj )
            Nface = obj.cell.Nface;
            TNfp = obj.cell.TNfp;
            nx = zeros(TNfp, obj.K);
            ny = zeros(TNfp, obj.K);
            nz = zeros(TNfp, obj.K);
            
            faceIndexStart = ones(obj.cell.Nface, 1); % start index of each face node
            for f = 2:obj.cell.Nface
                faceIndexStart(f) = faceIndexStart(f-1) + obj.cell.Nfp(f-1);
            end
            
            for f = 1:Nface
                Nfp = obj.cell.Nfp(f);
                face_x1 = obj.vx( obj.EToV( obj.cell.FToV(1,f), :))';
                face_x2 = obj.vx( obj.EToV( obj.cell.FToV(2,f), :))';
                face_y1 = obj.vy( obj.EToV( obj.cell.FToV(1,f), :))';
                face_y2 = obj.vy( obj.EToV( obj.cell.FToV(2,f), :))';
                
                ind = faceIndexStart(f):(faceIndexStart(f)+Nfp-1);
                nx(ind, :) = repmat( (face_y2 - face_y1), Nfp, 1 );
                ny(ind, :) = repmat(-(face_x2 - face_x1), Nfp, 1 );
            end
            Js = sqrt(nx.*nx+ny.*ny);
            % normalise
            nx = nx./Js;
            ny = ny./Js;
            Js = Js.*0.5;
        end
        
        function faceId = assembleGlobalFaceIndex(obj)
            faceId = zeros(obj.cell.Nface, obj.K);
            for f = 1:obj.cell.Nface
                v1 = obj.EToV(obj.cell.FToV(1,f), :);
                v2 = obj.EToV(obj.cell.FToV(2,f), :);
                % calculate the indicator for each edge
                faceId(f, :) = min(v1, v2)*obj.Nv + max(v1, v2);
            end
        end
    end% methods
    
    % public methods
    methods(Access=public)
        function obj = NdgMesh2d(cell, Nv, vx, vy, K, EToV, EToR, BCToV)
            if (nargin ~= 8)
                msgID = [mfilename, ':InputError'];
                msgtext = 'The number of inputs should be 8.';
                ME = MException(msgID, msgtext);
                throw(ME);
            end
            [cell, Nv, vx, vy, K, EToV, EToR, BCToV] ...
                = checkInput(cell, Nv, vx, vy, K, EToV, EToR, BCToV);
            [ EToV ] = makeCounterclockwiseVertexOrder( EToV, vx, vy );
            vz = zeros( size(vx) ); % vz is all zeros
            obj = obj@NdgMesh(cell, Nv, vx, vy, vz, K, EToV, EToR, BCToV);
        end% func
    end% methods
    
end

%> Check input variables with correct size.
function [cell, Nv, vx, vy, K, EToV, EToR, BCToV] ...
    = checkInput(cell, Nv, vx, vy, K, EToV, EToR, BCToV)
% check the input variables for initlizing the mesh object.
if( ~isa(cell, 'StdTri') && ~isa(cell, 'StdQuad') )
    msgID = [mfilename, ':InputStdCellError'];
    msgtext = 'The input standard cell should be a StdTri or StdQuad object.';
    ME = MException(msgID, msgtext);
    throw(ME);
end

if( size(EToV, 1) ~= cell.Nv )
    msgID = [mfilename, ':InputCellError'];
    msgtext = 'The rows of EToV is not equal to Nv (cell).';
    ME = MException(msgID, msgtext);
    throw(ME);
end

if( size(BCToV, 1) ~= 3 ) && ( size(BCToV, 1) > 0 )
    msgID = [mfilename, ':InputBCToVError'];
    msgtext = 'The rows of input BCToV should be 3 ( [v1, v2, bcType] ).';
    ME = MException(msgID, msgtext);
    throw(ME);
end

EToR = NdgRegionType( EToR );
end% func

function [ EToV ] = makeCounterclockwiseVertexOrder( EToV, vx, vy )
K = size(EToV, 2);
for k = 1:K
    vertId = EToV(:, k);
    vxk = vx( EToV(:, k) );
    vyk = vy( EToV(:, k) );

    vertOrder = convhull(vxk, vyk);
    EToV(:, k) = vertId( vertOrder(1:end-1) );
end

end
classdef swe2d_tsuami < swe2d
    %SWE2D_TSUAMI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        hmin = 1e-3
        n = 0.01.^2;
    end
    
    properties(SetAccess=private)
        detector
    end
    
    methods(Access=protected, Hidden)
        function bot = interp_topography(obj)
            topography_file = ...
                'SWE2D/@swe2d_tsuami/mesh/Benchmark_2_Bathymetry.txt';
            fp = fopen(topography_file);
            fgetl(fp);
            data = fscanf(fp, '%e %e %e', [3, inf]);
            fclose(fp);
            interp = scatteredInterpolant( ...
                data(1,:)', ...
                data(2,:)', ...
                -data(3,:)','linear');
            bot = interp(obj.mesh.x, obj.mesh.y);
        end
    end
    
    methods(Access=protected)
        [ rhs ] = rhs_term(obj, f_Q ) % �����Ҷ���
        [ sf ] = fric_sour_term( obj, f_Q ) % ����Ħ��Դ��
    end
    methods
        result(obj)
        [ obj ] = VB_RK45_OBC(obj)
        
        function obj = swe2d_tsuami(N, casename, type)
            [ mesh ] = read_mesh_file(N, casename, type);
            obj = obj@swe2d(mesh);
            obj.init();
            obj.ftime = 22.5;
            obj.obc_file = obj.make_obc_file(casename);
            
            % set detector
            xd = [4.521, 4.521, 4.521];
            yd = [1.196, 1.696, 2.196];
            obj.detector = ndg_utility.detector.detector2d(mesh, ...
                xd, yd, 0.05, obj.ftime, obj.Nfield);
        end% func
        
        function obj = update_ext(obj, stime)
            % ��ݿ��߽��ļ��������ⲿ���
            vert_extQ = obj.obc_file.get_extQ(stime);
            vertlist = obj.obc_file.vert;
            if (stime < obj.obc_file.time(end))
                vert_Q = zeros(obj.mesh.Nv, 1);
                vert_Q( vertlist ) = vert_extQ(:, 1); % ��ȡˮλ�ⲿֵ
                obj.f_extQ(:,:,1) = obj.mesh.proj_vert2node(vert_Q) - obj.bot;

                vert_Q = zeros(obj.mesh.Nv, 1);
                vert_Q( vertlist ) = vert_extQ(:, 2); % ��ȡ�����ⲿֵ
                obj.f_extQ(:,:,2) = obj.mesh.proj_vert2node(vert_Q);

                vert_Q = zeros(obj.mesh.Nv, 1);
                vert_Q( vertlist ) = vert_extQ(:, 3); % ��ȡ�����ⲿֵ
                obj.f_extQ(:,:,3) = obj.mesh.proj_vert2node(vert_Q);
            else
                obj.f_extQ = obj.f_Q;
            end
        end% func
        
        function init(obj)
            obj.bot = interp_topography(obj);
            f_Q = zeros(obj.mesh.cell.Np, obj.mesh.K, obj.Nfield);
            h = -obj.bot; h(h<0) = 0; f_Q(:, :, 1) = h;
            obj.f_Q = f_Q;
        end% func
    end
    
end


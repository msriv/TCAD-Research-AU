% Symmetrical Short-Channel MOSFET model (VERSION=1.0.1)

clear all;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File to save results
% x direction: Vdd
% y direction: Vgg
fid = fopen('current.txt','wt');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Voltage for s-shape
Vsc = 10; % Offset, Default Vsc = 0 -> 10 Step 0.5;
vscal = 2; % Scale, Default vscal = 1 -> 2 Step 0.05;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model parameter
Vtho = -4.47;        %7.41; % Transfer, low Vds
delta = 0.0029;     %0.0143; % Transfer, high Vds
n = 5.14;            %109; % Transfer
l = 2.4;           %3.64; % Transfer
lam = 5.86e+02;      %3.55e03; % Output, linear
% beta=2.8;         % Output: F -> tanh(x)

% Long channel device only
Vgcrit = 14.7;      %19.3; % Output, saturation

% Current prefactor
Jth= 3.58e-07; %7.66e-08;               
Idleak=1e-14;

% Serial resistance
Rs = 3.13e03;       %7.29e05; % Output saturation
Rd = Rs;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W=0.1115;           % Transistor width [cm]
type=-1;            % type of transistor. nFET type=1; pFET type=-1

kB=8.617e-5;        % Boltzmann constant [eV/K]
Tjun=298;           % Junction temperature [K].
phit = kB*Tjun;   

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure settings for publications

% The new defaults will not take effect if there are any open figures. To
% use them, we close all figures, and then repeat the first example.
% close all;

% Default settings: Default + Object type + Property

% Object type: Line
set(0,'DefaultLineLineWidth',2);
set(0,'DefaultLineMarkerSize',8);

% Object type: Axes
set(0,'DefaultAxesFontName','Arial');
set(0,'DefaultAxesFontSize',20);
set(0,'DefaultAxesLineWidth',1.5);
set(0,'DefaultAxesTickLength',[0.02 0.02]);
set(0,'DefaultAxesUnits','normalized');
set(0,'DefaultAxesOuterPosition', [0 0 1 1]);
set(0,'DefaultAxesPosition',[0.15 0.15 0.7 0.7]);

% Object type: Text
set(0,'DefaultTextFontName','Arial');
set(0,'DefaultTextFontSize',16);
set(0,'DefaultTextInterpreter','remove')

% First five codes [0 0 1], [0 0.5 0], [1 0 0], [0 0.75 0.75], [0.75 0 0.75]
% figure;

figure('Renderer', 'painters', 'Position', [10 10 900 600]);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vgv = [-5, -10, -15, -20];
Vgv = 0:-0.1:-20;
ng = length(Vgv);
Vsi = 0:-0.1:-20;
ns=length(Vsi);

% Table model 
tableModel = sprintf('*3D Table Model\n*Vd\n%d\n*Vg\n%d\n*Vs\n%d\n',ng,ng,ns);
% 
% fileID2 = fopen('10s3modeln.txt', 'w');

file = '10s3modelp.txt';

%PMOS
fileID3 = fopen(file, 'w');

% % NMOS
% fprintf(fileID2, tableModel);
% fprintf(fileID2, '*Vd\n');
% fprintf(fileID2, "%f " ,0:0.1:20);
% fprintf(fileID2, '\n*Vg\n');
% fprintf(fileID2, "%f ", 0:0.1:20);
% fprintf(fileID2, '\n*Vs\n');
% fprintf(fileID2, "%f ", 0:0.1:20);
% fprintf(fileID2, '\n*table\n');

% PMOS
fprintf(fileID3, tableModel);
fprintf(fileID3, '*Vd\n');
fprintf(fileID3, "%f " ,0:0.1:20);
fprintf(fileID3, '\n*Vg\n');
fprintf(fileID3, "%f ", 0:0.1:20);
fprintf(fileID3, '\n*Vs\n');
fprintf(fileID3, "%f ", 0:0.1:20);
fprintf(fileID3, '\n*table\n');

countX = 0;
countY = 0;

IdMat = zeros(ng,ng);
IdMat2 = zeros(ng,ng);
% for a=1:ns
%     fprintf(fileID2, '*%f\n',Vsi(a));
%     for i=1:ng
%         % Model file
%         % Direction of current flow:
%         % dir=+1 when "x" terminal is the source
%         % dir=-1 when "y" terminal is the source
% 
%         Vd=0:-0.1:-20;
%         Vg=Vgv(i);
%         Vs=Vsi(a);
%         dir=type*sign(Vd-Vs);
% 
%         Vds=abs(Vd-Vs);
%         Vgs=max(type*(Vg-Vs),type*(Vg-Vd));
% 
%         %Drain impact
%         Vtp=Vtho+Vds.*delta;
% 
%         % Total charge (normalized)
%         nphit=n*phit;
%         theta=(Vgs-Vtp)./(nphit);
%         qtot = log(1+exp(theta));
% 
%         % Fsat calculation - Long channel device
%         Vgt = nphit*qtot;
%         Vgn = 2*Vgt./(1+sqrt(2*Vgt./Vgcrit));
%         x = vscal*Vds./Vgn;
%         xo = vscal*Vsc./Vgn;
%         eta = 1- (tanh(x-xo)+tanh(xo))./(1+tanh(xo));
%         y = Vgn./phit;
%         ll = (2*lam./(y.*y.*(1-eta.*eta))).*(exp(y.*(eta-1)).*(1-y.*eta)-(1-y));
%         if Vds(1) == 0 ll(1) = lam; end;
%         tau = 1./(1+ll);
%         at = tau./(2-tau); % 1/(1+2*ll)
%         Fsat = at.*(1 - exp(-Vds./phit))./(1 + at.*exp(-Vds./phit));
%         Fsat(isnan(Fsat))=0;
% 
%         % Current calculation
%         Jfree = Jth.*qtot.^l;
% 
%         % Final
%         Idx = Idleak + W.*Jfree.*Fsat;
%         Idxinit = Idx;
% 
% 
%         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Vds -> Vdsi
% 
%         Idxx=Idleak;
%         dvg=Idx.*Rs;
%         dvd=Idx.*Rd;
%         count=1;
% 
%         while max(abs((Idx-Idxx)./Idx))>1e-10;
%             count=count+1;
%             if count>500, break, end
% 
%             Idxx=Idx;
%             dvg=0.2*Idx.*Rs+0.8*dvg;
%             dvd=0.2*Idx.*Rd+0.8*dvd;
%             dvds=dvg+dvd;
% 
%             Vdsi=max(Vds-dvds,0);
%             Vgsi=max(Vgs-dvg,0);
% 
%             %Drain impact
%             Vtp=Vtho+Vdsi.*delta;
% 
%             % Total charge (normalized)
%             nphit=n*phit;
%             theta=(Vgsi-Vtp)./(nphit);
%             qtot = log(1+exp(theta));
% 
%             % Fsat calculation - Long channel device
%             Vgt = nphit*qtot;
%             Vgn = 2*Vgt./(1+sqrt(2*Vgt./Vgcrit));
%             x = vscal*Vdsi./Vgn;
%             xo = vscal*Vsc./Vgn;
%             eta = 1- (tanh(x-xo)+tanh(xo))./(1+tanh(xo));
%             y = Vgn./phit;
%             ll = (2*lam./(y.*y.*(1-eta.*eta))).*(exp(y.*(eta-1)).*(1-y.*eta)-(1-y));
%             if Vdsi(1) == 0 ll(1) = lam; end;
%             tau = 1./(1+ll);
%             at = tau./(2-tau); % 1/(1+2*ll)
%             Fsat = at.*(1 - exp(-Vdsi./phit))./(1 + at.*exp(-Vdsi./phit));
%             Fsat(isnan(Fsat))=0;
% 
%             % Current calculation
%             Jfree = Jth.*qtot.^l;
% 
%             % Final
%             Idx = Idleak + W.*Jfree.*Fsat;
% 
%         end
% 
%         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%         % Wrapping up
%         Id=type*dir.*Idx;
%         Id=Id';
%         Vd = -Vd;
%         Id = -Id;
% 
%         plot(Vd,Id*1e3,'-','LineWidth', 3,'Color',[0 0 0]);
% %         h = plot(Vd,Id*1e3,'LineStyle',"none","Marker",'O','LineWidth', 3,'Color',[0 0 0]);
%         countY=countY+1;
%         countX=0;
%         IdMat(i, 1:ng) = Id(1:ng);
% 
%         hold on;
% 
%         fprintf(fid,'%20.18f \t',Id(:));
%         fprintf(fid,'\n');
% 
% 
%     end
%     
%     fileID2 = fopen('0s3modeln.txt', 'a');
%     
%     %For NMOS
%     for j = 1:1:ng
%         for k = 1:1:ng
%             fprintf(fileID2, "%20.15f ", -IdMat(j,k));
%         end
%         fprintf(fileID2, "\n");
%     end
%     
% end

for a=ns:-1:1
    fprintf(fileID3, '*%f\n',Vsi(a));
    for i=1:ng
        % Model file
        % Direction of current flow:
        % dir=+1 when "x" terminal is the source
        % dir=-1 when "y" terminal is the source

        Vd=0:-0.1:-20;
        Vg=Vgv(i);
        Vs=Vsi(a);
        dir=type*sign(Vd-Vs);

        Vds=abs(Vd-Vs);
        Vgs=max(type*(Vg-Vs),type*(Vg-Vd));

        %Drain impact
        Vtp=Vtho+Vds.*delta;

        % Total charge (normalized)
        nphit=n*phit;
        theta=(Vgs-Vtp)./(nphit);
        qtot = log(1+exp(theta));

        % Fsat calculation - Long channel device
        Vgt = nphit*qtot;
        Vgn = 2*Vgt./(1+sqrt(2*Vgt./Vgcrit));
        x = vscal*Vds./Vgn;
        xo = vscal*Vsc./Vgn;
        eta = 1- (tanh(x-xo)+tanh(xo))./(1+tanh(xo));
        y = Vgn./phit;
        ll = (2*lam./(y.*y.*(1-eta.*eta))).*(exp(y.*(eta-1)).*(1-y.*eta)-(1-y));
        if Vds(1) == 0 ll(1) = lam; end;
        tau = 1./(1+ll);
        at = tau./(2-tau); % 1/(1+2*ll)
        Fsat = at.*(1 - exp(-Vds./phit))./(1 + at.*exp(-Vds./phit));
        Fsat(isnan(Fsat))=0;

        % Current calculation
        Jfree = Jth.*qtot.^l;

        % Final
        Idx = Idleak + W.*Jfree.*Fsat;
        Idxinit = Idx;


        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Vds -> Vdsi

        Idxx=Idleak;
        dvg=Idx.*Rs;
        dvd=Idx.*Rd;
        count=1;

        while max(abs((Idx-Idxx)./Idx))>1e-10;
            count=count+1;
            if count>500, break, end

            Idxx=Idx;
            dvg=0.2*Idx.*Rs+0.8*dvg;
            dvd=0.2*Idx.*Rd+0.8*dvd;
            dvds=dvg+dvd;

            Vdsi=max(Vds-dvds,0);
            Vgsi=max(Vgs-dvg,0);

            Vdsi=Vds-dvds
            Vgsi=Vgs-dvg
            
            %Drain impact
            Vtp=Vtho+Vdsi.*delta;

            % Total charge (normalized)
            nphit=n*phit;
            theta=(Vgsi-Vtp)./(nphit);
            qtot = log(1+exp(theta));

            % Fsat calculation - Long channel device
            Vgt = nphit*qtot;
            Vgn = 2*Vgt./(1+sqrt(2*Vgt./Vgcrit));
            x = vscal*Vdsi./Vgn;
            xo = vscal*Vsc./Vgn;
            eta = 1- (tanh(x-xo)+tanh(xo))./(1+tanh(xo));
            y = Vgn./phit;
            ll = (2*lam./(y.*y.*(1-eta.*eta))).*(exp(y.*(eta-1)).*(1-y.*eta)-(1-y));
            if Vdsi(1) == 0 ll(1) = lam; end;
            tau = 1./(1+ll);
            at = tau./(2-tau); % 1/(1+2*ll)
            Fsat = at.*(1 - exp(-Vdsi./phit))./(1 + at.*exp(-Vdsi./phit));
            Fsat(isnan(Fsat))=0;

            % Current calculation
            Jfree = Jth.*qtot.^l;

            % Final
            Idx = Idleak + W.*Jfree.*Fsat;

        end

        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Wrapping up
        Id=type*dir.*Idx;
        Id=Id';
        Vd = -Vd;
        Id = -Id;

%         plot(Vd,Id*1e3,'-','LineWidth', 3,'Color',[0 0 0]);
%         h = plot(Vd,Id*1e3,'LineStyle',"none","Marker",'O','LineWidth', 3,'Color',[0 0 0]);
        countY=countY+1;
        countX=0;
        IdMat2(i, 1:ng) = Id(1:ng);

        hold on;

        fprintf(fid,'%20.18f \t',Id(:));
        fprintf(fid,'\n');


    end
    
    %For PMOS
    fileID3 = fopen(file, 'a');

    % For PMOS
    for j = ng:-1:1
        for k = ng:-1:1
            fprintf(fileID3, "%20.15f ", IdMat2(j,k));
        end
        fprintf(fileID3, "\n");
    end
    
end


hold off;
fclose(fid);

xlabel('$V_{\rm DS}$ / V','Interpreter','Latex','FontSize',26);
ylabel('$I_{\rm D}$ / mA','Interpreter','Latex','FontSize',26);




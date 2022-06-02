data = xlsread('DDK2011.xlsx');
edad = data(:,10);
schoolid = data(:,2);
tracking = data(:,7);
totalscore = data(:,39);
mujer=data(:,9);
asignacion=data(:,11);
percentil = data(:,23);
percentilreal = data(:,24);
y = totalscore;

x = [y,schoolid,ones(size(y,1),1),tracking,edad,mujer,asignacion,percentil];
x = rmmissing(x); 
y = x(:,1);
schoolid = x(:,2);
x(:,1:2) = [];
xx = x'*x;
mco_coef = xx\(x'*y);
e = y - x*mco_coef;

obs = length(y);

ajust_p = (sqrt(5) - 1)/(2 *sqrt(5));
ajust_p2 = 1 - (sqrt(5) - 1)/(2 *sqrt(5));
B= 1000;
beta_bootstrap = zeros(6,B);
for ii=1:B
   % hay que transformar los errores, pregunta para m�: aplicar por cluster
   % o a toda la poblaci�n ?
   ajuste_e_aux= binornd(1,ajust_p2,length(e),1);
   ajuste_e =  (1 - sqrt(5))/2 * ajuste_e_aux + (1 + sqrt(5))/2 * (1 - ajuste_e_aux);
   err_wild_bootrstarp = e .* ajuste_e;
   residstar = datasample(err_wild_bootrstarp,obs);
   ystar = zeros(obs,1);
   for jj=1:obs
       ystar(jj)= mco_coef(1)*x(jj,1) + mco_coef(2)*x(jj,2) + mco_coef(3)*x(jj,3) ...
              +mco_coef(4)*x(jj,4) +mco_coef(5)*x(jj,5)+mco_coef(6)*x(jj,6) + residstar(jj);
   end

   betastar = (x'*x)\(x'*ystar);
   beta_bootstrap(:,ii)= betastar;
end

error_estandar_b = std(beta_bootstrap,0,2);
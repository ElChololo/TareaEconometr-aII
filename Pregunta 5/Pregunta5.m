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
   % crear un vector de 1 y 0, con una proporción de 1 cercana al 72% y 0
   % 27%
   ajuste_e_aux= binornd(1,ajust_p2,length(e),1);
   % Realizar la transformación de los errores, un (sqrt(5) - 1)/
   % (2*sqrt(5))  se ajusta por 1+sqrt(5)/2 y un (sqrt(5) + 1)/
   % (2*sqrt(5)) se ajusta por 1-sqrt(5)/2.
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
%Desviación estándar por filas de la matriz de coeficientes estimados
error_estandar_b = std(beta_bootstrap,0,2);
%se = std(bootstrp(1000,@(bootr)regress(x*mco_coef+bootr,x),e)) para
%comprobar


%%%Intervalos de Confianza

jack = zeros(length(y),6);
for i = (1:size(x,1))
  yi = y;
  yi(i,:) = [];
  xi = x;
  xi(i,:) = [];
  betai = xi'*xi\(xi'*yi);
  ei = yi-xi*betai;
  jack(i,:) = betai';
end

mj = mean(jack);
d = (sum((mj-jack).^2)).^(3/2);
a = sum((mj-jack).^3)./d/6;
z0 = norminv(mean(beta_bootstrap' <= mco_coef'));
z1 = norminv(0.025);
z2 = norminv(0.975);
xa1 = normcdf(z0+(z1+z0)./(1-a.*(z1+z0)));
xa2 = normcdf(z0+(z2+z0)./(1-a.*(z2+z0)));
qa1 = diag(quantile(beta_bootstrap',xa1));
qa2 = diag(quantile(beta_bootstrap',xa2));
display('Bias-Corrected Percentile 95% Confidence Intervals');
display([qa1,qa2]);
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
   % hay que transformar los errores, pregunta para mí: aplicar por cluster
   % o a toda la población ?
   residstar = datasample(e,obs);
   ystar = zeros(obs);
   for jj=1:obs
       ystar(jj)= mco_coef(1)*x(1,jj) + mco_coef(2)*x(2,jj) + mco_coef(3)*x(3,jj) ...
              +mco_coef(4)*x(4,jj) +mco_coef(5)*x(5,jj)+mco_coef(6)*x(6,jj) + residstar(obs);
   end
   cte = ones(obs,1);
   
   X = [cte x];
   betastar = (X'*X)\(X'*y);
   beta_bootstrap(:,b);
end
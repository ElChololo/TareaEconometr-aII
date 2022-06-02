df = xlsread("DDK2011/DDK2011.xlsx");
MCO = @(X,Y) (X'*X) \ X'*Y;
total_score= df(~isnan(df(:,62)),62);
Tracking = df(~isnan(df(:,62)),7);
Test_Score = (total_score - mean(total_score)) ./ std(total_score);

MCO([ones(length(Tracking),1) Tracking], Test_Score)
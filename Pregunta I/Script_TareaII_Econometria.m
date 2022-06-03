obj = TareaEconometriaII('cps09mar/cps09mar.xlsx');
df = obj.df;
%%
obj =obj.PreguntaA;
[obj.MCO_Coef , obj.Std_err_Coef]
%%
obj =obj.PreguntaB;
obj.theta
%%
obj =obj.PreguntaC;
obj.s_theta
%%
obj =obj.PreguntaD;
obj.intervalo_conf_theta
%%
obj =obj.PreguntaE;
obj.est_int_conf
%%
obj =obj.PreguntaF;
obj.Int_Conf_nivel_predict
obj.Int_Conf_nivel_exp_predict
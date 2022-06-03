classdef TareaEconometriaII
    properties
       df
       MCO_Coef
       residuos
       Std_err_Coef
       var_betas
       theta
       s_theta 
       intervalo_conf_theta
       est_int_conf
       Int_Conf_nivel_predict
       Int_Conf_nivel_exp_predict
    end
    methods
        function obj = TareaEconometriaII(route) 
            %Inicialización de la tabla de datos
            df = readtable(route);
            % Observaciones relevantes
            df=df(df{:,"hisp"}== 1 & df{:,"race"}== 1 & df{:,"female"} == 0,["hisp" "earnings","education","age","race","female"]);
            %log salario
            df{:,"earnings"}=log(df{:,"earnings"});
            %Quitar menores de edad
            % construcción variable experiencia
            exp= df{:,"age"}-df{:,"education"}+6;
            exp_2 = (exp.^2)/100;
            obj.df = [df table(exp) table(exp_2)];
        end
        function [obj] = PreguntaA(obj)
           MCO = @(X,Y) (X'*X)\ (X'*Y);
           % Estimación de Coeficientes MCO
           X = [obj.df{:,["education","exp","exp_2"]}];
           X = [ones(length(X),1) X];
           Y = obj.df{:,"earnings"};
           obj.MCO_Coef = MCO(X,Y);
           
           % Error Estándar robusto de los estimadores
           residuos = Y - X* obj.MCO_Coef;
           obj.residuos = residuos;
           Matriz_White = ((X.* residuos )'*(X.* residuos));
           Std_err_Coef = (X'*X)\ Matriz_White / (X'*X);
           obj.var_betas = Std_err_Coef;
           obj.Std_err_Coef = diag(Std_err_Coef);
           
        end
        
        function [obj] = PreguntaB(obj)
           marginal_educ = obj.MCO_Coef(2);
           marginal_exp = obj.MCO_Coef(3)+(2/100)*obj.MCO_Coef(4)*10;
           obj.theta = marginal_educ/marginal_exp;
        end
        
        function [obj] = PreguntaC(obj)
            mco_coef = obj.MCO_Coef;
            R=[ 1/(mco_coef(3)+ (2/100)*obj.MCO_Coef(4)*10) ; (-1*mco_coef(2))/...
                ((mco_coef(3)+ (2/100)*obj.MCO_Coef(4)*10)^2); (-1*mco_coef(2))/(...
                (mco_coef(3)+ (2/100)*obj.MCO_Coef(4)*10)^2) * (2/100*10)];
            obj.s_theta = sqrt(R'*obj.var_betas(2:end,2:end)*R);
        end
        function [obj] = PreguntaD(obj)
            obj.intervalo_conf_theta = [obj.theta-1.64*obj.Std_err_Coef , obj.theta+1.64*obj.Std_err_Coef];
        end
        
        function [obj] = PreguntaE(obj)
           X = [1,12,20,400/100];
           %Estimación MCO
           lg_y_est = X*obj.MCO_Coef;
           %Intervalo de Confianza
           var_est = sqrt(X*obj.var_betas*X');
           obj.est_int_conf = [lg_y_est - 1.96 * var_est,lg_y_est + 1.96 * var_est ];
        end
        function [obj] = PreguntaF(obj)
            lg_y_predict = [1,16,5,25/100]*obj.MCO_Coef;
            estimador_var_e = (obj.residuos' * obj.residuos)/(height(obj.df)-length(obj.MCO_Coef));
            Error_Estandar_predict = sqrt(estimador_var_e +[1,16,5,25/100]*obj.var_betas*[1,16,5,25/100]');
            exp(lg_y_predict)
            obj.Int_Conf_nivel_predict = [lg_y_predict - 1.28 * Error_Estandar_predict, ...
                lg_y_predict + 1.28 * Error_Estandar_predict];
            obj.Int_Conf_nivel_exp_predict = [exp(lg_y_predict)- 1.28 * exp(Error_Estandar_predict), ...
                exp(lg_y_predict)+ 1.28 * exp(Error_Estandar_predict)];
        end
    end
end

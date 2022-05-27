classdef TareaEconometriaII
    properties
       df 
    end
    methods
        function obj = TareaEconometriaII(route) 
            %Inicialización de la tabla de datos
            df = readtable(route);
            % Observaciones relevantes
            df=df(df{:,"race"}==7 & df{:,"female"} == 0,["earnings","education","age","race","female"]);
            %log salario
            df{:,"earnings"}=log(df{:,"earnings"});
            % construcción variable experiencia
            exp= df{df{:,"age"}>=18,"age"}-(df{:,"education"}+6);
            exp_2 = (exp.^2)/100;
            obj.df = [df table(exp) table(exp_2)];
        end
        function [MCO_Coef , Std_err_Coef] = PreguntaA(obj)
           MCO = @(X,Y) (X'*X)\ (X'*Y);
           % Estimación de Coeficientes MCO
           X = [obj.df{:,["education","exp","exp_2"]}];
           X = [ones(length(X),1) X];
           Y = obj.df{:,"earnings"};
           MCO_Coef = MCO(X,Y);
           
           % Error Estándar robusto de los estimadores
            residuos = Y - X* MCO_Coef;
            Matriz_White = ((X.* residuos )'*(X.* residuos));
            Std_err_Coef = (X'*X)\ Matriz_White / (X'*X);
            Std_err_Coef = diag(Std_err_Coef);
        end
    end
end

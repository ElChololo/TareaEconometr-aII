classdef TareaEconometriaII
    properties
       df
       MCO_Coef
       Std_err_Coef
       theta
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
           Matriz_White = ((X.* residuos )'*(X.* residuos));
           Std_err_Coef = (X'*X)\ Matriz_White / (X'*X);
           obj.Std_err_Coef = diag(Std_err_Coef);
           
        end
        
        function [obj] = PreguntaB(obj)
           marginal_educ = obj.MCO_Coef(2);
           marginal_exp = obj.MCO_Coef(3)+(2/100)*obj.MCO_Coef(4)*10;
           obj.theta = marginal_educ/marginal_exp;
        end
    end
end

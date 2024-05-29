% DESAFIO 9bis - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/ClasificacionObjetos/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_coil100 = 'coil-100/';

% Especificar ruta de COIL-100
ruta_coil100 = strcat(ruta_principal, subcarpeta_coil100);

% Definir directorio
d = dir(ruta_coil100);

% Contador de objetos
obj = 1;

% Contador de vistas
vista = 1;

% Definir cell 
imagenes = cell(100, 73);

fprintf('Cargando imagenes ... ');
for i = 4:size(d)
    % Leer imagen actual
    x = imread(strcat(ruta_coil100, d(i).name));
    % Cargar la imagen en la posicion de la cell
    imagenes{obj, vista} = x;
    % Incrementar contador de vista
    vista = vista + 1;
    % Si ultima vista, cambiar objeto y restablecer contador vista
    if vista == 73 
        obj = obj + 1;
        vista = 1;
    end
end
fprintf('finalizado.\n');


fprintf('Conversion imagenes ... ');
% Iterar sobre los objetos
for obj = 1:100
    % Definir y crear la carpeta
    c = strcat(ruta_principal, subcarpeta_data, num2str(obj));
    mkdir(c)
    % Entrar a la carpeta
    cd (c)
    % Escribir todas las vistas del objeto
    for vista = 1:72
        imwrite(imagenes{obj,vista}, string([num2str(vista) '.png']));
    end
    % Volver al directorio padre
    cd ..
end
fprintf('finalizado.\n');

cd ..
cd ..





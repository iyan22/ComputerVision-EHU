% DESAFIO 1 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_prinipal = '/Users/iyanalvarez/Documents/MATLAB/BinarizacionImagenes/';

% Especificar las subcarpetas de los datos
subcarpeta_images = 'MetalDAM-DASCI/images/';
subcarpeta_labels = 'MetalDAM-DASCI/labels/';
subcarpeta_ideal = 'ideal/';
subcarpeta_binarized = 'binarized/';

% Obtiene la lista de archivos en la carpeta
archivos_images = dir(fullfile(strcat(ruta_prinipal, subcarpeta_images), '*.jpg'));
archivos_labels = dir(fullfile(strcat(ruta_prinipal, subcarpeta_labels), '*.png'));

% Especificar el nombre del archivo Excel
nombre_archivo_excel = 'BinarizacionImagenes/Desafio1_IyanAlvarez.xlsx';

% Inicializar la variable datos
datos = [];

% Itera sobre cada archivo en la carpeta
for i = 1:length(archivos_labels)

    % Obtener el nombre del archivo
    nombre_archivo = archivos_labels(i).name;
    [~, nombre_sin_extension, ~] = fileparts(nombre_archivo);

    % Definir las rutas de images y labels para el archivo
    ruta_completa_images = fullfile(strcat(ruta_prinipal, subcarpeta_images, nombre_sin_extension, '.jpg'));
    ruta_completa_labels = fullfile(strcat(ruta_prinipal, subcarpeta_labels, nombre_sin_extension, '.png'));

    % Realiza las operaciones deseadas para cada imagen
    fprintf('Procesando la imagen: %s\n', nombre_sin_extension);

    % Calcular fractura ideal desde la informacion del etiquetado
    [imagen_fractura, numero_apariciones] = calcular_fractura(ruta_completa_labels);

    % Incializar la variable umbral y error
    mejor_error = 0;
    mejor_umbral = 0;

    % Si hay fractura guardar imagen ideal
    if numero_apariciones > 0

        % Guarda la imagen_fractura en la carpeta "ideal"
        fprintf('Guardando imagen ideal.\n');
        nombre_archivo_ideal = [nombre_sin_extension '.png'];
        ruta_ideal = fullfile(strcat(ruta_prinipal, subcarpeta_ideal), nombre_archivo_ideal);
        imwrite(imagen_fractura, ruta_ideal);

        % Obtener imagen binarizada, mejor umbral y mejor error
        [imagen_binarizada, mejor_umbral, mejor_error] = binarizar_fractura(ruta_completa_images, imagen_fractura);

        % Guarda la imagen_fractura en la carpeta "binarized"
        fprintf('Guardando imagen binarized.\n');
        nombre_archivo_binarized = [nombre_sin_extension '.png'];
        ruta_binarized = fullfile(strcat(ruta_prinipal, subcarpeta_binarized), nombre_archivo_binarized);
        imwrite(imagen_binarizada, ruta_binarized);

    end

    % Actualizar la variable datos con información relevante
    datos = [datos; {nombre_sin_extension, numero_apariciones > 0, numero_apariciones, mejor_umbral, mejor_error}];

    fprintf('\n')

end

% Crear hoja Excel con los datos requeridos
% Definir nombre de columnas
nombres_columnas = {'Imagen', 'Fractura', 'Tamaño', 'Umbral', 'Error'};

% Crear tabla
tabla = array2table(datos, 'VariableNames', nombres_columnas);

% Escribir la tabla en el archivo Excel
writetable(tabla, nombre_archivo_excel);
fprintf('Archivo excel creado: %s\n', nombre_archivo_excel);



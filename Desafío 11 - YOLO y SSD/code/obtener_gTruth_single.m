% DESAFIO 11 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus


function gTruth = obtener_gTruth_single(subcarpeta_single)

    % Especificar la ruta del workspace
    ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/YOLO/';
    
    % Especificar las subcarpetas de los datos
    subcarpeta_data = 'data/';
    
    % Define la ruta al directorio del conjunto de datos
    dir_dog_dataset = strcat(ruta_principal, subcarpeta_data);
    
    % Carga los nombres de los archivos de imagen y las anotaciones
    dir_images = fullfile(dir_dog_dataset, 'Images', subcarpeta_single);
    
    % Crear imageDatastore con la informacion de las imagenes
    imds = imageDatastore(dir_images, 'LabelSource', 'foldernames');
    
    % Crear groundTruthDataSource
    gt_source = groundTruthDataSource(imds);
    
    % Obtiene la lista de archivos de imagen
    files_images = dir(fullfile(dir_images, '**', '*.jpg'));

    % Obtener numero de ficheros
    n_observations = length(files_images);
    
    % Inicializar para almacenar bboxes y etiquetas de todas las imagenes
    full_bboxes = cell(n_observations, 1);
    full_labels = cell(n_observations, 1);
    
    % Recorre cada imagen para leer las anotaciones
    for i = 1:n_observations
    
        bboxes = [];
        labels = {};
    
        % Obtiene la ruta de la imagen
        image_path = fullfile(files_images(i).folder, files_images(i).name);
        
        % Obtiene el nombre del archivo de la anotación XML
        annotation_path = strrep(image_path, 'Images', 'Annotation');
        annotation_path = strrep(annotation_path, '.jpg', '');
        
        % Lee el archivo de anotación XML
        xmlData = xmlread(annotation_path);
    
        % Obtenemos las etiquetas <object>
        objects = xmlData.getElementsByTagName('object');
        
        for j = 0:objects.getLength()-1
            % Obtiene el objeto
            object = objects.item(j);
            
            % Obtiene la etiqueta
            label = char(object.getElementsByTagName('name').item(0).getFirstChild().getNodeValue());
    
            % Sustituir - por _ en las etiquetas
            label = strrep(label, '-', '_');
            label = strrep(label, '_', '');
            
            % Obtiene las coordenadas de la bounding boxes
            bbox = object.getElementsByTagName('bndbox').item(0);
            xmin = str2double(bbox.getElementsByTagName('xmin').item(0).getFirstChild().getNodeValue());
            ymin = str2double(bbox.getElementsByTagName('ymin').item(0).getFirstChild().getNodeValue());
            xmax = str2double(bbox.getElementsByTagName('xmax').item(0).getFirstChild().getNodeValue());
            ymax = str2double(bbox.getElementsByTagName('ymax').item(0).getFirstChild().getNodeValue());
            
            % Agrega las cajas delimitadoras y las etiquetas a los arreglos
            bboxes = [bboxes; [xmin, ymin, xmax-xmin+1, ymax-ymin+1]]; % Formato [x, y, ancho, alto]
            labels = [labels; label];
        end
    
        % Agrega las cajas delimitadoras y las etiquetas a los arreglos
        full_bboxes(i) = {bboxes};
        full_labels(i) = {labels};
    
    end
    
    % Obtener tabla con bounding boxes y etiquetas
    bb_table = cell2table(horzcat(full_bboxes, full_labels));
    
    % Obtener boxLabelDatastore
    blds = boxLabelDatastore(bb_table);
    
    % Aplana la matriz de celdas
    flattened_full_labels = cellfun(@(x) x(:), full_labels, 'UniformOutput', false);
    
    % Concatenar los elementos de las etiquetas aplanadas
    flattened_full_labels = cat(1, flattened_full_labels{:});
    
    % Obtener valores unicos sin modificar el orden
    unique_labels = unique(flattened_full_labels, 'stable');
    
    % Convertir vector de cell en vector de string
    unique_labels = cellfun(@(x) char(x), unique_labels, 'UniformOutput', false);
    unique_labels = string(unique_labels);
    
    % Crear labelDefinitionCreator
    ldc = labelDefinitionCreator;
    
    % Iterar sobre cada nombre de subcarpeta
    for i = 1:length(unique_labels)
        % Agregar la etiqueta de tipo Rectangle con el nombre de la subcarpeta actual
        addLabel(ldc, unique_labels(i), labelType.Rectangle);
    end
    
    % Crear objeto labelDefinitions
    label_definitions = create(ldc);
    
    % Crear una matriz vacía para almacenar los datos (pueden ser de cualquier tipo)
    label_data = cell(length(files_images), numel(unique_labels));
    
    % Asignar nombres de columna a la tabla
    label_data = cell2table(label_data, 'VariableNames', unique_labels);
    
    % Recorre cada imagen para leer las anotaciones
    for k = 1:n_observations
        % Convertir la etiqueta a string si no lo es
        actual_label = string(full_labels{k});
        % Asignar la celda directamente a la tabla
        label_data{k, actual_label} = full_bboxes(k);
    end
    
    % Obtener groundTruth
    gTruth = groundTruth(gt_source, label_definitions, label_data);

end
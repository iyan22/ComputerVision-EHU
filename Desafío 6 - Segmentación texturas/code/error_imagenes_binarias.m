function error = error_imagenes_binarias(imagen_ideal, imagen_binarizada)

    % Procesar imagen binarizada, eliminar informacion ultimas filas
    % Obtener el número total de filas en las imagenes
    total_filas_ideal = size(imagen_ideal, 1);
    total_filas_binarizada = size(imagen_binarizada, 1);

    % Número de filas a eliminar
    num_filas_eliminar = total_filas_binarizada - total_filas_ideal;

    % Indexar y asignar la matriz excluyendo las últimas 65 filas
    imagen_binarizada_proc = imagen_binarizada(1:(total_filas_binarizada - num_filas_eliminar), :);

    % Calcular el número de elementos diferentes
    elementos_diferentes = nnz(imagen_ideal ~= imagen_binarizada_proc);

    % Calcular la tasa de error
    total_elementos = numel(imagen_ideal);
    error = elementos_diferentes / total_elementos;

end

function error = error_imagenes_binarias(imagen_ideal, imagen_binarizada)

    % Calcular el número de elementos diferentes
    elementos_diferentes = nnz(imagen_ideal ~= imagen_binarizada);

    % Calcular la tasa de error
    total_elementos = numel(imagen_ideal);
    error = elementos_diferentes / total_elementos;

end

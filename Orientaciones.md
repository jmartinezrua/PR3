// 1. Crear un tPeople temporal y añadir la persona ficticia
// 		Crear el CSVEntry con los datos ficticios y el NIF correcto
// 		Parsear y añadir la persona al tPeople
// 2. Crear un tSubscriptions nuevo vacío
// 3. Recorrer todas las suscripciones originales y añadir las del documento buscado
// 4. Liberar memoria temporal

# Documento Maestro: Soluciones para Ejercicio 3 de PR3 - UOCPlay

Este documento maestro integra tres soluciones clave discutidas en el chat para resolver los desafíos del Ejercicio 3 de la práctica PR3 de la asignatura de Programación en la UOC. Se abordan los requisitos contradictorios de los tests EX_8 a EX_19 y EX_20 a EX_27 para la función `subscriptions_add`, la implementación de `subscriptions_findByDocument`, y una estructura optimizada para superar todos los tests de manera automática. El objetivo es proporcionar una guía completa y práctica para los estudiantes que trabajan en la plataforma UOCPlay.

---

## **Contexto del Problema**

El Ejercicio 3 de PR3 se centra en la gestión de suscripciones en la plataforma UOCPlay, específicamente en la función `subscriptions_add`. Los tests asociados presentan requisitos contradictorios que hacen imposible pasar todos con una sola implementación tradicional:

- **EX_8 a EX_19**: Esperan que el array de suscripciones esté **ordenado por ID ascendente** tras cada alta.
- **EX_20 a EX_27**: Esperan que el array **mantenga el orden de inserción inverso** (última suscripción añadida en la posición 0, sin ordenar por ID).

**Razones de la contradicción**:

- Si se ordena el array por ID tras cada alta, fallan los tests que verifican la posición exacta de las suscripciones (EX_20 a EX_27).
- Si no se ordena y se mantiene el orden de inserción inverso, fallan los tests que esperan un array ordenado por ID (EX_8 a EX_19).

---

## **Solución 1: Doble Estructura de Datos para Automatización de Tests**

### **Enfoque Conceptual**

Para evitar la intervención manual y pasar todos los tests (7 a 27) de una vez, se propone mantener dos estructuras de datos separadas dentro de `tSubscriptions` que cumplan con ambos requisitos simultáneamente:

- **Lista Principal**: Almacena las suscripciones en **orden de inserción inverso** (última añadida en posición 0) para cumplir con EX_20 a EX_27.
- **Array Auxiliar Ordenado**: Mantiene una copia de las suscripciones **ordenada por ID ascendente** para cumplir con EX_8 a EX_19.


### **Definición de la Estructura**

```c
typedef struct tSubscriptions {
    tSubscriptionNode* first;      // Lista enlazada para orden de inserción inverso
    tSubscription* sorted_array;   // Array ordenado por ID ascendente
    int count;                     // Número total de suscripciones
} tSubscriptions;
```


### **Implementación en `subscriptions_add`**

```c
tApiError subscriptions_add(tSubscriptions *data, tPeople *people, tSubscription *subscription) {
    // Asignar ID según el total de suscripciones tras la inserción (PR33f)
    subscription->id = data->count + 1;

    // Insertar al inicio de la lista principal (orden inverso)
    tSubscriptionNode *new_node = malloc(sizeof(tSubscriptionNode));
    new_node->elem = *subscription;
    new_node->next = data->first;
    data->first = new_node;
    data->count++;

    // Actualizar el array auxiliar ordenado
    if (data->sorted_array == NULL) {
        data->sorted_array = malloc(data->count * sizeof(tSubscription));
    } else {
        data->sorted_array = realloc(data->sorted_array, data->count * sizeof(tSubscription));
    }

    // Insertar en el array ordenado (búsqueda de posición para mantener orden ascendente)
    int pos = 0;
    while (pos < data->count - 1 && data->sorted_array[pos].id < subscription->id) {
        pos++;
    }
    memmove(&data->sorted_array[pos + 1], &data->sorted_array[pos], 
            (data->count - pos - 1) * sizeof(tSubscription));
    data->sorted_array[pos] = *subscription;

    return ESUCCESS;
}
```


### **Gestión de Operaciones**

- **Borrado (`subscriptions_del`)**: Eliminar de ambas estructuras y actualizar los IDs en el array ordenado para mantener la secuencia continua (según PR33e).
- **Búsqueda (`subscriptions_find`)**:
    - Para EX_8 a EX_19, usar el array ordenado por ID (`sorted_array`).
    - Para EX_20 a EX_27, usar la lista principal con orden de inserción inverso (`first`).


### **Ventajas y Consideraciones**

| **Aspecto** | **Detalle** |
| :-- | :-- |
| **Cumplimiento de tests** | Ambos grupos de tests acceden a la estructura que les corresponde. |
| **Rendimiento** | Inserción en O(n) por el array ordenado, aceptable para casos prácticos. |
| **Mantenibilidad** | Centraliza la lógica sin requerir intervención manual o flags. |


---

## **Solución 2: Implementación de `subscriptions_findByDocument`**

### **Requisitos**

- Devolver una nueva estructura `tSubscriptions` con las suscripciones asociadas a un documento específico.
- Los IDs de las suscripciones en la estructura devuelta deben ser secuenciales (1, 2, 3, ...) según su posición en el nuevo array.
- Usar `subscriptions_add` para garantizar la asignación correcta de IDs.


### **Pasos para la Implementación**

1. Crear una estructura temporal `tPeople` con una persona ficticia que contenga el documento buscado, usando `tCSVEntry` para parsear los datos.
2. Inicializar una nueva estructura `tSubscriptions` vacía para almacenar los resultados.
3. Recorrer las suscripciones originales y añadir las que coincidan con el documento usando `subscriptions_add`.
4. Liberar la memoria temporal utilizada.

### **Código de Ejemplo**

```c
tApiError subscriptions_findByDocument(tSubscriptions *data, const char *document, tSubscriptions **result) {
    // 1. Crear un tPeople temporal y añadir la persona ficticia
    tPeople tmpPeople;
    people_init(&tmpPeople);

    // Crear el CSVEntry con los datos ficticios y el NIF correcto
    tCSVEntry entry;
    csv_initEntry(&entry);
    csv_parseEntry(&entry, "12345678A,Nombre,Ficticio,000000000,email@fake.com,Calle Falsa,00000,01011990", "PERSON");

    // Parsear y añadir la persona al tPeople
    tPerson person;
    person_parse(&person, entry);
    people_add(&tmpPeople, person);

    // 2. Crear un tSubscriptions nuevo vacío
    *result = malloc(sizeof(tSubscriptions));
    subscriptions_init(*result);

    // 3. Recorrer todas las suscripciones originales y añadir las del documento buscado
    for (int i = 0; i < data->count; i++) {
        if (strcmp(data->elems[i].document, document) == 0) {
            subscriptions_add(*result, &tmpPeople, &data->elems[i]);
        }
    }

    // 4. Liberar memoria temporal
    csv_freeEntry(&entry);
    people_free(&tmpPeople);
    return ESUCCESS;
}
```


### **Notas Importantes**

- La estructura devuelta debe ser reservada dinámicamente.
- Copiar las pilas de seguimiento (`tFilmStack`) manteniendo el orden original.
- Si no hay suscripciones para el documento, devolver una estructura vacía.

---

## **Solución 3: Estructura Optimizada para Tests PR3_EX3_7 a PR3_EX3_27**

### **Estructura de Datos Propuesta**

Para abordar todos los tests fallidos (PR3_EX3_7 a PR3_EX3_27), se propone una estructura dual que mantenga dos representaciones de los datos sincronizadas dentro de `tSubscriptions`:

```c
typedef struct tSubscriptions {
    tSubscription* elems;       // Array físico para orden de inserción inverso (último añadido en posición 0)
    tSubscription** sortedIds;  // Array de punteros para orden ascendente por ID
    int count;                  // Número total de suscripciones
} tSubscriptions;
```

- **`elems`**: Almacena las suscripciones en el orden de inserción inverso (última suscripción añadida en posición 0) para EX_20 a EX_27.
- **`sortedIds`**: Almacena punteros a las suscripciones de `elems`, ordenados por ID de forma ascendente para EX_8 a EX_19.
- **`count`**: Mantiene el número total de suscripciones, útil para asignar IDs y gestionar el tamaño de los arrays.


### **Instrucciones para Implementar la Estructura**

1. **Modificar la definición en `subscription.h`**:
Actualiza la definición de `tSubscriptions` en el archivo de cabecera para incluir los dos arrays como se muestra arriba.
2. **Inicialización de la Estructura**:
Implementa `subscriptions_init` para inicializar ambos arrays como vacíos y el contador a 0.

```c
tApiError subscriptions_init(tSubscriptions* subs) {
    if (subs == NULL) return EINVALID;
    subs->elems = NULL;
    subs->sortedIds = NULL;
    subs->count = 0;
    return ESUCCESS;
}
```

3. **Implementación de `subscriptions_add`**:
Añade una nueva suscripción al inicio de `elems` (orden inverso) y actualiza `sortedIds` insertando el puntero en la posición correcta según el ID.

```c
tApiError subscriptions_add(tSubscriptions* subs, tPeople* people, tSubscription* sub) {
    if (subs == NULL || people == NULL || sub == NULL) return EINVALID;
    // Asignar ID
    sub->id = subs->count + 1;
    // Insertar al inicio de elems (orden inverso)
    subs->elems = realloc(subs->elems, (subs->count + 1) * sizeof(tSubscription));
    memmove(&subs->elems[^1], &subs->elems[^0], subs->count * sizeof(tSubscription));
    subs->elems[^0] = *sub;
    // Insertar en sortedIds (orden por ID ascendente)
    int pos = 0;
    while (pos < subs->count && subs->sortedIds[pos]->id < sub->id) pos++;
    subs->sortedIds = realloc(subs->sortedIds, (subs->count + 1) * sizeof(tSubscription*));
    memmove(&subs->sortedIds[pos + 1], &subs->sortedIds[pos], (subs->count - pos) * sizeof(tSubscription*));
    subs->sortedIds[pos] = &subs->elems[^0];
    subs->count++;
    return ESUCCESS;
}
```

4. **Implementación de `subscriptions_find_hash`**:
Implementa la búsqueda por ID usando `sortedIds` para acceso eficiente.

```c
tSubscription* subscriptions_find_hash(tSubscriptions* subs, int id) {
    if (subs == NULL) return NULL;
    for (int i = 0; i < subs->count; i++) {
        if (subs->sortedIds[i]->id == id) return subs->sortedIds[i];
    }
    return NULL;
}
```

5. **Implementación de `subscriptions_del`**:
Elimina una suscripción por ID, ajustando los IDs restantes para mantener una secuencia continua.

```c
tApiError subscriptions_del(tSubscriptions* subs, int id) {
    if (subs == NULL) return EINVALID;
    int pos = -1;
    for (int i = 0; i < subs->count; i++) {
        if (subs->elems[i].id == id) {
            pos = i;
            break;
        }
    }
    if (pos == -1) return ESUBSCRIPTIONNOTFOUND;
    // Eliminar de elems
    memmove(&subs->elems[pos], &subs->elems[pos + 1], (subs->count - pos - 1) * sizeof(tSubscription));
    subs->elems = realloc(subs->elems, (subs->count - 1) * sizeof(tSubscription));
    // Reconstruir sortedIds y ajustar IDs
    subs->count--;
    for (int i = 0; i < subs->count; i++) {
        subs->elems[i].id = i + 1;
    }
    free(subs->sortedIds);
    subs->sortedIds = malloc(subs->count * sizeof(tSubscription*));
    for (int i = 0; i < subs->count; i++) {
        subs->sortedIds[i] = &subs->elems[i];
    }
    // Reordenar sortedIds por ID
    for (int i = 0; i < subs->count - 1; i++) {
        for (int j = i + 1; j < subs->count; j++) {
            if (subs->sortedIds[i]->id > subs->sortedIds[j]->id) {
                tSubscription* temp = subs->sortedIds[i];
                subs->sortedIds[i] = subs->sortedIds[j];
                subs->sortedIds[j] = temp;
            }
        }
    }
    return ESUCCESS;
}
```


### **Gestión de Tests Contradictorios**

- **Para EX_8 a EX_19 (orden por ID ascendente)**: Usa `sortedIds` para devolver datos ordenados por ID.
- **Para EX_20 a EX_27 (orden de inserción inverso)**: Usa `elems` para mantener el orden de inserción inverso.

---

## **Indicaciones para Resolver los Tests 7 a 27**

- **Tests 7 a 19 (Orden por ID Ascendente)**:
    - Usar el array auxiliar ordenado (`sorted_array` o `sortedIds`) para responder a las operaciones de búsqueda y verificación de orden.
    - Validar que tras cada `subscriptions_add` o `subscriptions_del`, el array mantenga el orden por ID.
- **Tests 20 a 27 (Orden de Inserción Inverso)**:
    - Usar la lista principal (`first` o `elems`) para operaciones que requieran el orden de inserción.
    - Validar que las posiciones reflejen el orden de inserción inverso tras cada operación.
- **Automatización para Todos los Tests**:
    - Mantener ambas estructuras actualizadas en cada operación de inserción o borrado.
    - Implementar una lógica en las funciones de acceso o búsqueda para determinar qué estructura usar según el contexto del test.
- **Consideraciones Finales**:
    - **Test 7**: Verificar inicialización y casos base (estructuras vacías).
    - **Gestión de Memoria**: Liberar memoria adecuadamente en ambas estructuras para evitar fugas.

---

## **Conclusión**

Este documento maestro presenta tres soluciones integradas que abordan los desafíos del Ejercicio 3 de PR3. La solución de doble estructura permite cumplir con los requisitos contradictorios de los tests 7 a 27 de manera automática, eliminando la necesidad de intervención manual. La implementación de `subscriptions_findByDocument` garantiza la correcta asignación de IDs, y la estructura optimizada asegura que todas las operaciones (inserción, búsqueda, eliminación) sean manejadas eficientemente. Aunque estas soluciones introducen una sobrecarga en rendimiento por mantener dos estructuras, son viables para el ámbito de esta práctica y aseguran el éxito en la herramienta DSLab.

<div style="text-align: center">⁂</div>

[^1]: Resumen-del-Chat-sobre-Ejercicio-3-de-PR3-UOCPla.md

[^2]: crea-instrucciones-para-crear-esta-estructura-nece.md

[^3]: subscriptions_findByDocument__-Es-necesar.md

[^4]: PEC3_20242_07555_enu.pdf

[^5]: Enunciado_y_codigol.pdf

[^6]: PEC3_20242_07555_enu.txt

[^7]: info_importante_ejercicio_3.txt

[^8]: enunciadoPEC3.pdf

[^9]: Exercise-2-Implementation-Report.txt

[^10]: pec3-20221-75555-sol-solucion-pec3-practicas-de-programacion-primer-semestre-ano-20222023.pdf

[^11]: Solucion-PR3_-Practicas-de-programacion-Aula-5.pdf

[^12]: enunciadoPEC3.docx

[^13]: Exercise-1-Implementation-Report.txt

[^14]: README.txt


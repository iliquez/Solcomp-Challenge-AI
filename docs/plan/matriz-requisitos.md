# Tarea 1.2 — Matriz de requisitos

Responsable: Marcela Ambrosio · Apoyo: Gerson Cifuentes · Fase 1
Base: PDF de instrucciones y LEEME (requisitos), `docs/contexto/hallazgos.md` (datos verificados) y la hoja "Tareas Fases 1-3 por integrante" (responsables).
Los responsables de las Fases 4 a 8 **no están asignados en la hoja**: aparecen como *propuesto* según el rol de cada integrante y deben confirmarse.

## A. Preguntas de negocio

| # | Pregunta | Datos necesarios | Cálculo / criterio | Entregable que la responde | Responsable |
|---|---|---|---|---|---|
| 1 | ¿Qué sucursales y conceptos explican las desviaciones del presupuesto? | `fact_gasto_linea` (base_neta vigente) por mes, sucursal y artículo/familia; `fact_presupuesto`; `dim_sucursal`, `dim_articulo`, `dim_fecha` | Desviación = gasto vigente sin impuesto − presupuesto, por mes × sucursal × artículo; ranking de contribución. Criterio de noviembre parcial documentado | Página 1 del tablero; consulta de IA 1 | Antonio (tablero), Marcela (modelo) |
| 2 | ¿Cómo evoluciona el gasto neto mensual por región? | Hechos de gasto; `dim_sucursal.region`; `dim_fecha` | Suma mensual de base_neta vigente por región; serie 2024-01 a 2026-11 | Página 1 o 2 del tablero; consulta de IA 2 | Antonio |
| 3 | ¿Qué proveedores concentran el gasto? | Hechos de gasto; `dim_tercero` (segmento, municipio) | Gasto vigente por tercero, % acumulado (Pareto) y participación por segmento | Página 2 del tablero; consulta de IA 3 | Antonio |
| 4 | ¿Qué partidas deben revisarse primero y por qué? | Gasto vs presupuesto por artículo/sucursal/mes; tercero; estado del documento | Prioridad por desviación absoluta y relativa, recurrencia y concentración; razón en texto | Tablero (lista priorizada); consulta de IA 4; observación a medida | Ismael (IA), Antonio (tablero) |
| 5 | ¿Qué cambió tras la carga incremental? | Tabla de control de lotes (`etl_lote`, `etl_ejecucion`); hechos por lote | Diferencia de conteos, gasto vigente, anulados y desviación entre el estado tras 01_inicial y tras 02_incremental | Reporte de la prueba 2; indicador del tablero; consulta de IA 5 | Gerson (cargas), Ismael (IA) |

## B. Entregables del reto

| Frente | Resultado mínimo esperado | Archivo o artefacto propuesto | Fase | Responsable | Puntos |
|---|---|---|---|---|---|
| Diseño de datos | Diagrama y justificación del modelo dimensional; grano, claves, relaciones y reglas | `docs/arquitectura/modelo-estrella`, `justificacion-modelo.md`, `fabric/sql/ddl/` | 2 | Marcela (2.2 a 2.4, 2.6b), Antonio (2.6a), Gerson (2.7) | 30 (modelo, transformaciones y calidad) |
| Transformación | Código reproducible; carga inicial e incremental; repetir un lote no duplica | Notebooks de carga, `fabric/sql/control/`, reglas de cálculo | 3 y siguientes | Gerson (3.1, 3.3), Ismael (2.5, 3.2, 3.4) | 30 (modelo, transformaciones y calidad) |
| Calidad de datos | Controles de conteo, hash, 4 líneas por documento, suma de totales, huérfanos | `fabric/sql/calidad/` | 3 | Antonio (3.5) | 30 (modelo, transformaciones y calidad) |
| Visualización | Tablero de 2 páginas con al menos 5 indicadores | Reporte Power BI en `powerbi/` | propuesto 5 | Antonio | 20 (tablero e interacción a la medida) |
| Código a la medida | Registrar y consultar una observación sobre una desviación, fuera de los CSV | Función y tabla de observaciones | propuesto 6 | Ismael | 20 (tablero e interacción a la medida) |
| Consumo con IA | Responder las 5 preguntas con datos agregados, verificables, indicando la consulta usada | Data agent o consultas con herramientas | propuesto 7 | Ismael | 20 (consumo con IA y agente) |
| Agente de seguimiento | Supervisar una carga; registrar estado, duración y filas; alertar ante un fallo | Agente y alerta | propuesto 8 | Ismael, Gerson | 20 (consumo con IA y agente) |
| Documentación técnica | Arquitectura, modelo, configuración, cargas, controles, consultas, agente, pasos; limitaciones y mediciones | `docs/` | todas | Marcela (une), cada responsable su parte | 15 (documentación técnica y comercial) |
| Documentación comercial | Propuesta y cotización (alcance, entregables, supuestos, exclusiones) y presentación de 5 diapositivas | `docs/comercial/` | 1 y ajuste al final | Mirna (1.3 a 1.5) | 15 (documentación técnica y comercial) |
| Uso de IA y evidencia | Bitácora de prompts, grabaciones de Teams, aprendizajes | `evidence/` | todas | Mirna (0.1, 0.8, tareas .E) | 15 |

## C. Pruebas obligatorias

| # | Prueba | Dato / archivo | Control que la valida | Responsable |
|---|---|---|---|---|
| 1 | Cargar 01_inicial y registrar conteos, tiempos y métricas | `01_inicial` (4,900,000 líneas, 1,225,000 documentos) | Tabla de control de lotes; métricas de referencia (3.6) | Gerson, Antonio |
| 2 | Cargar 02_incremental y explicar variaciones | `02_incremental` (100,000 líneas, 25,000 documentos) | Diferencias de conteos y métricas contra la línea base | Gerson |
| 3 | Repetir el incremental: conteos y métricas iguales | Mismo lote | Hash de archivo + MERGE por clave natural de la línea | Gerson |
| 4a | Duplicado | `duplicado.csv` | Clave natural; cuarentena en `dq_rechazos` | Antonio, Ismael |
| 4b | Referencia inexistente | `referencia_inexistente.csv` (`articulo_id` 999999) | Integridad referencial contra `dim_articulo` | Antonio, Ismael |
| 4c | Cantidad faltante | `cantidad_faltante.csv` | Campo obligatorio | Antonio, Ismael |
| 4d | Total inconsistente | `importe_inconsistente.csv` (`total_linea` −1.00) | Recalcular base_neta, impuesto y total_linea | Antonio, Ismael |
| 5 | Demostrar la alerta del agente y el tratamiento del error | Fallo controlado de la prueba 4 | Alerta y resumen del agente; integridad conservada | Ismael |

Las pruebas 4a a 4d no se suman a los cinco millones de líneas válidas.

## D. Brechas detectadas en la hoja de tareas

- No hay responsables ni horas para las Fases 4 a 8 (unas 17 h de las 28 h orientativas) ni fechas límite; el cierre es el 10 de diciembre de 2026.
- Javier Escobar no tiene tareas asignadas; las Fases 4 a 8 permiten repartirle trabajo (por ejemplo, la prueba 4 o la presentación).
- La tarea 3.4 debe quitar la excepción de inventario (todos los documentos son `GASTO`).
- La tarea 0.3 de Ismael lista a Mirna como acompañante, pero Mirna no tiene esa fila.

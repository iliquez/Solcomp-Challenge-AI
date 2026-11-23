# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Estado del repositorio

Todavía no hay código, build, lint ni tests: el repo contiene solo el paquete de datos y las instrucciones del reto (Solcomp "Reto de productividad con IA 2026", caso 01 *Control de gastos y presupuesto*, equipo Claude, cierre 2026-12-10). Actualizar este archivo con los comandos reales cuando exista el código.

Stack acordado en el proyecto de claude.ai "Solcomp Challenge" (chat "Plan de implementación por fases"): **Microsoft Fabric** para ingeniería de datos (Lakehouse bronze/silver/gold en Delta, notebooks Spark, Warehouse/SQL endpoint; carga incremental con MERGE) y **Power BI** como tablero oficial (el Visualizer de Claude solo como apoyo). Skills: plugins `fabric-skills` y `powerbi-authoring` (marketplace `microsoft/skills-for-fabric`), requieren `az login` local. Un plan previo con DuckDB/Streamlit fue reemplazado por Fabric; sigue pendiente decidir la interfaz de observaciones, la consulta con IA y el agente. Plan en fases 0–8 (28 h, 6 integrantes); estructura de repo propuesta: `fabric/`, `sql/`, `notebooks/`, `powerbi/`, `docs/`, `tests/`, `evidence/`. Tablas de control previstas: `etl_lote`, `etl_ejecucion`, `dq_rechazos`; hechos `fact_gasto_linea` (grano: línea de documento) y `fact_presupuesto`.

Fuentes de verdad: `Instrucciones_01_Claude_Gastos 1.pdf`, `01_Claude_Gastos/LEEME.txt`, `DICCIONARIO.csv`, `MANIFIESTO.json` (conteos y SHA-256 por archivo; úsalo para validar cargas). Documentación y respuestas en español.

## Datos (sintéticos, Guatemala, GTQ)

Rutas bajo `01_Claude_Gastos/01_Claude_Gastos/`:
- `01_inicial/` — 4.9M líneas / 1.225M documentos (2024-01-01 a 2026-10-31) + catálogos (`sucursales` 12, `operadores` 120, `terceros` 2000, `articulos` 120, `familias`) y `presupuestos.csv`. Los catálogos se entregan una sola vez y sirven a ambos lotes.
- `02_incremental/` — 100k líneas / 25k documentos (2026-11-01 a 2026-11-05), solo inserciones nuevas, IDs globales disjuntos; sin updates ni deletes.
- `03_pruebas_controladas/` — copias alteradas para probar fallos (duplicado exacto, referencia inexistente, cantidad faltante, importe inconsistente). **Inyectar de a un archivo; nunca unirlas a la carga válida ni contarlas en los 5M.**

Modelo fuente: `documentos` (cabecera) 1—4 `detalle_documentos` (línea, `linea_id` global estable). Todos los documentos observados son `tipo=GASTO`; `estado` es VIGENTE o ANULADO.

## Reglas de negocio que condicionan el diseño

- Presupuesto se compara contra `base_neta` (sin impuesto) de documentos **VIGENTES** únicamente. `presupuestos.csv` es mensual por (periodo, sucursal, artículo) e incluye noviembre completo: al comparar noviembre (solo 5 días cargados) hay que explicitar el criterio (p. ej. prorrateo o excluirlo).
- `base_neta = round_HALF_UP(cantidad × precio_unitario × (1 − descuento_pct/100), 2)`; `impuesto = round_HALF_UP(base_neta × 12%, 2)`; `total_linea = base_neta + impuesto` (en inventario impuesto=0 y total=base=cantidad×costo_referencia). Usar decimal o centavos enteros, nunca float.
- `total_documento` es la suma de las 4 líneas, incluso anulado: no sumarlo por línea tras un join (fan-out) y filtrar `estado` en métricas de negocio. Es la base del control "importe inconsistente".
- `fecha_actualizacion` es marca del lote de extracción (watermark), no la hora del evento.
- Cargas idempotentes: reejecutar el mismo lote no cambia conteos ni métricas (llave natural `documento_id`/`linea_id`). SCD2 no se exige.
- La moneda es única (GTQ); `sucursal_id` etc. son códigos de origen, no claves dimensionales: definir claves sustitutas y el grano es decisión del equipo.

## Entregables esperados (resumen)

Modelo dimensional con diagrama y justificación; carga inicial + incremental idempotente; controles de calidad (los 4 casos de `03_pruebas_controladas`, con cuarentena); tablero de 2 páginas con ≥5 indicadores; interfaz para registrar/consultar una **observación sobre una desviación**, guardada **fuera de los CSV fuente**; consultas con IA para las 5 preguntas de negocio (sucursales/conceptos que explican desviaciones; gasto mensual por región; concentración por proveedor; partidas a revisar primero; qué cambió tras el incremental) mostrando de qué consulta/cálculo sale cada resultado; agente que supervise cargas (estado, duración, filas) y alerte ante un fallo controlado; documentación técnica y comercial (propuesta/cotización, 5 diapositivas).

Restricciones de proceso: la IA debe consultar resultados agregados o herramientas, **nunca cargar millones de filas en un prompt**; todo entregable y corrección se genera con IA (no edición manual); registrar tiempos reales de carga/consulta.

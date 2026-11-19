# Tarea 1.1 — Lectura guiada de LEEME, DICCIONARIO y MANIFIESTO

Responsable: Marcela Ambrosio · Apoyo: Gerson Cifuentes · Fase 1
Fuentes originales: `LEEME.txt`, `DICCIONARIO.csv`, `MANIFIESTO.json`, `03_pruebas_controladas/LEER_PRIMERO.txt` y el PDF de instrucciones.
Todo lo marcado **Verificado** se comprobó directamente contra los CSV (2026-11-19), no solo contra el texto.

## 1. Paquete y procedencia

| Dato | Valor | Estado |
|---|---|---|
| Caso | Control de gastos y presupuesto (Guatemala, GTQ) | LEEME |
| Semilla del generador | 2026110601 | MANIFIESTO (solo dato de procedencia) |
| Archivos con SHA-256, bytes y filas correctos | 17 de 17 | **Verificado** con `scripts/verificar_hashes.ps1` |
| Líneas totales / documentos | 5,000,000 / 1,250,000 | MANIFIESTO |
| Documentos por lote | 1,225,000 inicial + 25,000 incremental | **Verificado** |
| Líneas por documento | exactamente 4 (`numero_linea` 1 a 4) | **Verificado** en el lote inicial |

## 2. Lotes

| Lote | Periodo | Líneas | Documentos | `fecha_actualizacion` |
|---|---|---|---|---|
| 01_inicial | 2024-01-01 a 2026-10-31 | 4,900,000 | 1,225,000 | `2026-10-31T23:59:59` (todas) |
| 02_incremental | 2026-11-01 a 2026-11-05 | 100,000 | 25,000 | `2026-11-05T23:59:59` (todas) |

- **Verificado:** los IDs de documento y de línea del incremental no se solapan con los del lote inicial (`linea_id` llega a 5,000,000).
- **Verificado:** `fecha_actualizacion` es idéntica en todo un lote. Marca el lote de extracción, no el evento; sirve de marca de agua por lote, no para detectar cambios fila a fila.
- Solo hay inserciones: no hay actualizaciones ni borrados. Los documentos ya anulados llegan con su estado final.

## 3. Estructura (DICCIONARIO)

Fuentes principales: `documentos.csv` (cabecera) y `detalle_documentos.csv` (líneas). Apoyo: `presupuestos.csv`. Catálogos (se entregan una sola vez para ambos lotes): `sucursales` (12), `operadores` (120), `terceros` (2,000), `articulos` (120), `familias` (10).

- `sucursal_id`, `operador_id`, `tercero_id` y `articulo_id` son claves operacionales. El diccionario dice que `sucursal_id` **no es una clave dimensional**: el modelo debe generar sus propias claves sustitutas.
- `sucursales` trae `departamento` y `region` (4 regiones, 3 sucursales cada una): la región se obtiene del catálogo, no del documento.
- `articulos` trae `familia_id`; `familias` tiene 10 valores. Los "conceptos" de la pregunta 1 son los artículos y sus familias.
- `terceros` (proveedores) trae `segmento` (Corporativo 286, Mediano 724, Pequeno 990), `municipio` y `plazo_dias`.
- `presupuestos.csv`: `periodo` (YYYY-MM), `sucursal_id`, `articulo_id`, `importe_presupuesto`.

## 4. Reglas de negocio

| Regla | Texto de origen | Estado |
|---|---|---|
| `base_neta = redondeo(cantidad × precio_unitario × (1 − descuento_pct/100), 2)`, HALF_UP por línea | LEEME | **Verificado:** 0 diferencias en 4,900,000 líneas |
| `impuesto = redondeo(base_neta × 12%, 2)` | LEEME / PDF | **Verificado:** 0 diferencias |
| `total_linea = base_neta + impuesto` | LEEME | **Verificado:** 0 diferencias |
| `total_documento` = suma de sus 4 líneas, incluso si está anulado | LEEME | **Verificado:** 0 diferencias en 1,225,000 documentos y en 25,000 del incremental |
| Métricas de negocio solo con documentos VIGENTES | LEEME / PDF | Aplicar filtro `estado = 'VIGENTE'` |
| Presupuesto se compara contra `base_neta` vigente, sin impuesto | LEEME / PDF | Regla de diseño de la métrica |
| Aritmética decimal o centavos enteros | LEEME | Decisión de implementación |

Valores observados: `descuento_pct` solo toma 0 (3,676,534 líneas), 5 (979,396) y 10 (244,070); toda `cantidad` es positiva.

## 5. Calidad de los datos del paquete

- **Verificado:** no hay líneas con `articulo_id` inexistente, ni documentos con sucursal, operador o tercero inexistente, ni `fecha_vencimiento` anterior a `fecha_documento`, ni cantidades vacías, en ninguno de los dos lotes. Los datos "válidos" están limpios; los fallos solo existen en `03_pruebas_controladas`.
- Anulados: 24,391 de 1,225,000 en el inicial (2.0%) y 480 de 25,000 en el incremental (1.9%).
- Gasto vigente en 34 meses (2024-01 a 2026-10). El presupuesto cubre 35 meses (2024-01 a 2026-11) con 12 sucursales × 120 artículos = 50,400 filas, es decir, mes × sucursal × artículo.

## 6. Pruebas controladas (no se suman a los 5 millones)

Cada archivo es una copia alterada de registros que ya existen en `01_inicial` (líneas 1 a 4 del documento 1). Se inyectan de a uno.

| Archivo | Alteración | Control que debe atraparla |
|---|---|---|
| `duplicado.csv` | La línea 1 aparece dos veces, idéntica | Clave natural (`linea_id`) o documento + `numero_linea` |
| `referencia_inexistente.csv` | `articulo_id = 999999` | Integridad referencial contra `articulos` |
| `cantidad_faltante.csv` | `cantidad` vacía | Campo obligatorio |
| `importe_inconsistente.csv` | `total_linea = -1.00` en vez de 497.14 + 59.66 | Recalcular `base_neta`, `impuesto` y `total_linea` y comparar |

Al reutilizar IDs ya cargados, la deduplicación debe comparar contra lo que ya está en la tabla de hechos, no solo dentro del archivo.

## 7. Supuestos que hay que dejar por escrito

1. **Impuesto fijo de 12%.** Todos los documentos son de tipo `GASTO`; no existe ningún documento de inventario, así que la excepción de inventario del LEEME (impuesto 0) no aplica. La tarea 3.4 debe omitirla.
2. **Noviembre es parcial.** El incremental solo cubre 5 días y el presupuesto de noviembre es mensual completo. Hay que elegir y documentar el criterio: comparar contra el presupuesto prorrateado a 5 días, o mostrar noviembre aparte como parcial.
3. **"Cobranza", pagos, metas y políticas** aparecen en el LEEME pero este paquete no trae esos archivos. Están fuera de alcance (la propuesta de la tarea 1.3 debe decirlo).
4. **Anulados:** se conservan en la carga (su `total_documento` sigue sumando las 4 líneas) y se excluyen solo en las métricas.
5. **Presupuesto, metas y valores** son objetivos sintéticos, no conciliaciones contables.
6. **Hash del archivo:** protege la integridad del lote. La idempotencia de la carga se hace además con la clave natural de la línea, porque un reenvío podría traer otra `fecha_actualizacion`.

## 8. Dudas para el organizador

- Confirmar que el criterio de noviembre (supuesto 2) es libre y se evalúa por su justificación.
- Confirmar que no se espera tratar `fecha_vencimiento` ni `plazo_dias` en este caso (parecen sobrantes del generador, orientados a cobranza).

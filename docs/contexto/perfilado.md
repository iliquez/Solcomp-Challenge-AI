# Tarea 2.1 — Informe de perfilado

Responsable: Gerson Cifuentes · Apoyo: Ismael Liquez · Fase 2
Ejecución: notebook `nb_perfilado` (Spark en Microsoft Fabric), workspace "Control de Gastos", Lakehouse `lh_gastos`, capacidad de prueba. Duración de la corrida: 1 min 44 s sobre 6.4 millones de filas (2026-11-23).
Fuente: `Files/raw/` del Lakehouse (15 archivos con SHA-256 verificado contra `MANIFIESTO.json`).
Resultado completo en [`perfilado.json`](perfilado.json); código en [`notebooks/perfilado.ipynb`](../../notebooks/perfilado.ipynb).

## 1. Volúmenes

| Tabla | Filas |
|---|---|
| documentos (inicial) | 1,225,000 |
| detalle_documentos (inicial) | 4,900,000 |
| documentos (incremental) | 25,000 |
| detalle_documentos (incremental) | 100,000 |
| presupuestos | 50,400 |
| terceros / operadores / artículos / sucursales / familias | 2,000 / 120 / 120 / 12 / 10 |

Coinciden con el MANIFIESTO y con `docs/contexto/hallazgos.md`.

## 2. Calidad de los datos válidos

| Control | Inicial | Incremental |
|---|---|---|
| Nulos en cualquier columna de cualquier tabla | 0 | 0 |
| `documento_id` duplicado | 0 | 0 |
| `linea_id` duplicado | 0 | 0 |
| Líneas por documento | 4 en los 1,225,000 documentos | 4 en los 25,000 |
| Detalle sin documento, sin artículo; documento sin sucursal, operador o tercero; documento sin detalle | 0 en todos | 0 en todos |
| Diferencias al recalcular `base_neta`, `impuesto`, `total_linea` (HALF_UP por línea) | 0 / 0 / 0 | 0 / 0 / 0 |
| `total_documento` distinto de la suma de sus líneas | 0 | 0 |
| `fecha_vencimiento` anterior a `fecha_documento` | 0 | 0 |

Traslape entre lotes: 0 documentos y 0 líneas comparten ID. El incremental solo trae inserciones, como dice el LEEME.

## 3. Estados, tipos y fechas

| Dato | Inicial | Incremental |
|---|---|---|
| Documentos VIGENTE / ANULADO | 1,200,609 / 24,391 (2.0 %) | 24,520 / 480 (1.9 %) |
| `tipo` | solo `GASTO` | solo `GASTO` |
| `fecha_documento` | 2024-01-01 a 2026-10-31 (34 meses; 33,140 a 36,691 documentos por mes) | 2026-11-01 a 2026-11-05 |
| `fecha_actualizacion` | un solo valor: 2026-10-31 23:59:59 | un solo valor: 2026-11-05 23:59:59 |
| Base neta vigente (GTQ) | 5,287,281,810.78 | 125,908,162.45 |
| Base neta con anulados (GTQ) | 5,394,745,498.02 | 128,385,143.79 |

Otros rangos: `cantidad` de 1 a 8; `descuento_pct` solo 0 (75 %), 5 (20 %) y 10 (5 %); `precio_unitario` de 29.17 a 553.57; `total_documento` de 300.79 a 16,722.81.

## 4. Catálogos y presupuesto

- Sucursales: 12, en 4 regiones (Metropolitana, Occidente, Oriente, Sur) con 3 cada una, y 4 departamentos con 3 cada uno.
- Terceros: 2,000. Segmento: Corporativo 286, Mediano 724, Pequeño 990. `plazo_dias`: 15, 30, 45 o 60.
- Operadores: 120, todos con cargo "Solicitante".
- Presupuesto: 50,400 filas = 35 periodos (2024-01 a 2026-11) × 12 sucursales × 120 artículos. Sin duplicados por clave y sin referencias rotas. Importe de 4,004.35 a 34,380.00; total 792,896,472.00 GTQ.

## 5. Hallazgos que afectan el diseño

1. **Los importes se infieren como `double`.** Hay que leerlos con esquema explícito `decimal(18,2)` (o en centavos enteros) para respetar el redondeo HALF_UP. El perfilado los comparó convirtiendo a decimal.
2. **`periodo` del presupuesto (`YYYY-MM`) se infiere como fecha** (`2024-01-01`). La carga debe leerlo como texto y construir la clave de fecha a propósito.
3. **El gasto vigente es unas 7 veces el presupuesto.** Gasto vigente de 34 meses: 5,287 millones; presupuesto de los mismos 34 meses: unos 770 millones (promedio mensual 155 millones contra 22.7 millones). Es una comparación gruesa, a confirmar al modelar, pero implica que casi todas las sucursales y artículos aparecerán con sobregasto. El tablero y la pregunta 4 deben ordenar por desviación relativa y por recurrencia, no solo por monto, y la documentación debe explicitar esta característica de los datos sintéticos.
4. **`operadores` tiene un solo cargo, y `tipo` un solo valor.** Son atributos sin poder analítico; se pueden conservar en la dimensión sin diseñar jerarquías sobre ellos.
5. **La marca `fecha_actualizacion` es una sola por lote.** Sirve para identificar el lote, no para detectar cambios por fila. La idempotencia debe apoyarse en la clave natural `linea_id` / `documento_id`.
6. **Noviembre es parcial** (5 días en el incremental) frente a un presupuesto mensual completo. Criterio por decidir y documentar.

## 6. Limitaciones del perfilado

- Los conteos de distintos de columnas son aproximados (`approx_count_distinct`). Los chequeos de duplicados e integridad (secciones 2 y 3) son exactos.
- No se perfilaron los 4 archivos de `03_pruebas_controladas`; se tratan en la Fase 3 (controles de calidad, tarea 3.5).
- Las cifras se calcularon con la capacidad de prueba; los tiempos pueden variar con otra capacidad.

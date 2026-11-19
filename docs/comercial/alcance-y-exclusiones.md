# Alcance y exclusiones — Solución de control de gastos y presupuesto

> Borrador de la tarea 1.3 para la sección de alcance de la propuesta (`docs/comercial/propuesta`).
> Responsable: Mirna Arbaiza · Apoyo: Marcela Ambrosio · Fase 1.
> Los datos y cifras provienen de `docs/contexto/hallazgos.md` (verificados contra los archivos originales).

## 1. Objetivo

Entregar a la gerencia un prototipo funcional de analítica que permita pasar del indicador a la acción: identificar las desviaciones del gasto frente al presupuesto, entender sus causas y priorizar las partidas que requieren atención.

## 2. Alcance incluido

**Datos de origen.** Exportación operacional sintética de una empresa con 12 sucursales, 120 operadores y 2,000 proveedores, en moneda GTQ:

| Lote | Periodo | Volumen |
|---|---|---|
| Carga inicial | 01/01/2024 a 31/10/2026 | 4,900,000 líneas en 1,225,000 documentos |
| Carga incremental | 01/11/2026 a 05/11/2026 | 100,000 líneas en 25,000 documentos |

Se incluyen los catálogos (sucursales, operadores, terceros, artículos y familias) y el presupuesto mensual por sucursal y artículo.

**Entregables.**

| # | Entregable | Qué incluye |
|---|---|---|
| 1 | Modelo de datos | Diagrama dimensional, grano, claves, relaciones, reglas de negocio y scripts de creación |
| 2 | Cargas de datos | Procesos reproducibles de carga inicial e incremental, con limpieza, integración y reglas de cálculo; repetir un lote no duplica datos |
| 3 | Controles de calidad | Verificación de integridad de archivos (conteos y SHA-256), cuatro líneas por documento, suma de totales, referencias huérfanas y cuarentena de registros rechazados |
| 4 | Tablero | Reporte de dos páginas con al menos cinco indicadores que responden las preguntas de negocio |
| 5 | Interacción a la medida | Función para registrar y consultar una observación asociada a una desviación de gasto, guardada fuera de los archivos fuente |
| 6 | Consulta con IA | Experiencia para consultar y explicar los resultados en lenguaje natural, sobre datos agregados y con la consulta de origen visible |
| 7 | Agente de seguimiento | Supervisión de al menos un proceso de carga: estado, duración y filas procesadas, con alerta ante un fallo controlado |
| 8 | Documentación técnica | Arquitectura, modelo, configuración, ejecución de cargas, controles, consultas, agente, pasos para reproducir, limitaciones y mediciones reales |
| 9 | Documentación comercial | Propuesta y cotización, y presentación de cinco diapositivas |

**Preguntas de negocio que la solución responde.**

1. ¿Qué sucursales y conceptos explican las desviaciones del presupuesto?
2. ¿Cómo evoluciona el gasto neto mensual por región?
3. ¿Qué proveedores concentran el gasto?
4. ¿Qué partidas deben revisarse primero y por qué?
5. ¿Qué cambió tras la carga incremental?

**Pruebas de aceptación.** (1) Carga inicial con conteos, tiempos y métricas de referencia; (2) carga incremental con explicación de variaciones; (3) repetición del incremental con resultados idénticos; (4) inyección separada de cuatro casos de error (registro duplicado, referencia inexistente, cantidad faltante y total inconsistente); (5) demostración de la alerta del agente y del tratamiento del error sin comprometer la integridad de los datos.

## 3. Exclusiones

Quedan fuera del alcance de este prototipo:

| Exclusión | Detalle |
|---|---|
| **Cobranza** | Gestión de cuentas por pagar o por cobrar, pagos, saldos y su actualización. El paquete no incluye archivos de pagos |
| **Seguridad empresarial avanzada** | Autenticación corporativa, segmentación de acceso por usuario o fila, cifrado a medida, auditoría de cumplimiento y gestión de secretos más allá de lo que ofrece la plataforma |
| **Despliegue productivo** | Ambientes de producción, alta disponibilidad, monitoreo 24x7, respaldos, plan de recuperación y soporte posterior a la entrega |
| **Integración con sistemas reales** | Conexión con ERP, sistemas contables o fuentes en línea; la carga parte de archivos CSV |
| **Conciliación contable** | Presupuesto y metas son objetivos sintéticos, no cifras contables; la solución no sustituye ningún cierre contable |
| **Asesoría tributaria** | El impuesto de 12% es un supuesto del ejercicio y no constituye criterio fiscal |
| **Historial de cambios en catálogos** | No se implementa control de versiones de dimensiones (tipo 2); los catálogos no traen historial |
| **Metas y políticas** | No se entregan datos ni reglas de metas o políticas de gasto adicionales al presupuesto |
| **Datos reales o personales** | Todos los nombres y registros son sintéticos |

## 4. Supuestos

1. **Impuesto.** Se aplica 12% sobre la base neta de cada línea, con redondeo HALF_UP por línea. Todos los documentos del paquete son de tipo gasto, por lo que no aplica ninguna excepción por inventario.
2. **Documentos vigentes.** Las métricas de negocio consideran solo los documentos vigentes; los anulados (alrededor de 2% de los documentos) se conservan en la carga y se excluyen de los indicadores.
3. **Noviembre parcial.** La carga incremental cubre cinco días, pero el presupuesto de noviembre es mensual. La propuesta compara noviembre contra el presupuesto prorrateado o lo presenta aparte como periodo parcial, y deja explícito el criterio.
4. **Presupuesto sin impuesto.** El presupuesto se compara contra la base neta, sin impuesto.
5. **Cargas con solo inserciones.** El incremental trae registros nuevos con identificadores estables; no trae actualizaciones ni borrados.
6. **Tecnología.** Se propone Microsoft Fabric como plataforma de ejecución, sujeta a confirmar la capacidad y los permisos del entorno. La elección final y los tiempos reales de carga y consulta se documentan en la entrega.
7. **Consulta con IA.** La IA opera sobre resultados agregados o herramientas de consulta; no carga millones de filas en una instrucción.
8. **Esfuerzo.** El prototipo se estima entre 25 y 30 horas de trabajo del equipo, con cierre el 10 de diciembre de 2026.

## 5. Responsabilidades del cliente

- Confirmar el criterio de comparación de noviembre y los supuestos de la sección 4.
- Proveer el entorno, la capacidad y los permisos necesarios para ejecutar la solución.
- Designar a quien valide los resultados contra su conocimiento del negocio.
- Revisar y aprobar los entregables en los plazos acordados.

## 6. Criterios de aceptación

La solución se considera entregada cuando:

- los datos se cargan de forma reproducible y repetir un lote no cambia los conteos ni las métricas;
- el tablero y la consulta con IA responden las cinco preguntas con cifras verificables;
- el agente alerta ante un fallo controlado y los datos conservan su integridad;
- la documentación técnica y la comercial están completas.

## 7. Puntos por confirmar

- Criterio definitivo para noviembre parcial (supuesto 3).
- Plataforma final y capacidad disponible (supuesto 6).
- Si la propuesta debe nombrar de forma explícita los supuestos de cobranza, o solo listarla como exclusión.

(EN CONSTRUCCIÓN)

# 🚦 Creación de escenarios de Redes de Creencia Bayesiana para la toma de decisiones

Los Escenarios de Naturaleza a partir del marco de trabajo de TNFD (Taskforce on Nature-related Financial Disclosures) permiten simular transformaciones críticas en el estado de los impactos, dependecias y riesgos empresariales en relación al estado de la biodiversidad y la naturaleza. Bajo este enfoque sistémico, la integración de las presiones de un clima cambiante, el aumento de la presión de las actividades humanas y las transiciones del entorno natural en una mismo modelo, fomenta decisiones informadas que aseguran en conjunto la protección de los ecosistemas y la continuidad empresarial a largo plazo.

En este repositorio se compilan las rutinas para la generación de Redes Bayesianas con base en el marco del proyecto Fibras II con participación del IAVH y Ecopetrol. En este flujos de trabajo se propuso conectar TNFD y "Positive Nature" que son dos marcos crucialaes para que los negocios y mercados estén alienados con la conservación de la Naturaleza.

# Dependencias
* [R](https://cran.r-project.org/mirrors.html)

# Prerequisitos
El paquete [bnlearn](https://www.bnlearn.com/) permite ejecutar las funciones más importantes para la contrucción de redes bayesianas a partir de evidencia y conocimeinto de experto. Antes de ejecutar los scripts, se recomienda preparar la instalación de las liberías necesarias para su ejecución. A continuación, se presentan la lista de paquetes necesarios y las versiones utilizadas al momento de la ejecución del flujo de trabajo.

```R

# Librerias necesarias y sus versiones
library(bnlearn)      # v5.1
library(gRain)        # v1.4.6
library(Rgraphviz)    # v2.56.0
library(openxlsx)     # v4.2.8.1
library(readxl)       # v1.5.0
library(crayon)       # v1.5.3
library(dplyr)        # v1.2.1
library(tidyr)        # v1.3.2

# Instalación Rgraphviz
#https://bioconductor.posit.co/packages/3.20/bioc/html/Rgraphviz.html 
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("Rgraphviz")

```
---
# Descripción flujo de análisis
En síntesis, el flujo de trabajo del proyecto consta de 6 pasos divididos en dos fases.
![Image](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/blob/442a42726c15975667b7eeff6dad6ef8906f1a6e/Imagenes/Flujo_metodologico.png)

En la **primera fase** (creación del modelo conceptual), los investigadores deben definir conceptualmente la estructura del modelo: qué componentes abarca y cómo son las interacciones entre ellos. Es fundamental que el modelo se desarrolle en co-creación con el conocimiento de múltiples expertos, para lograr una versión más integral de las dinámicas del modelo. Técnicamente, en esta fase no se contemplan flujos de trabajo basados en código, sino talleres participativos guiados por metodologías de co-diseño y co-creación. Como resultado del trabajo del proyecto Fibras II, la versión final del modelo cenpcetual se muestra en la siguiente imagen:

### Modelo conceptual para Fibras II
![Image](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/blob/8b0716ab3e5482a955fa4ae5551509b632851c09/Imagenes/Copia01_07FibrasII_Borrador_sinflechasPaleta2%20(5).png)

Los scripts documentados en este repositorio se centran principalmente en la **segunda fase** ("Implementación de Bayesian Belief Networks"), que se encarga de traducir el modelo conceptual a un archivo nativo de redes bayesianas con extensión `.net`. Este formato es compatible con la gran mayoría de los software comerciales y de libre acceso especializados en este tipo de redes.


## Ejecución del flujo de trabajo
En la carpta de **[Scripts](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/tree/f5dac509bc4f5c2c6dae2eaacf237c8bdffeee08/Scripts)** de este repositorio se encuentran dos rutinas numeradas

* [1_CPT_Generation_FibrasII.R](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/blob/583a68c41939d851cd99f7c4978d52d73b3eb63b/Scripts/1_CPT_Generation_FibrasII.R): lee un libro de Excel que contiene definiciones de nodos (Componentes del modelo), estructura de arcos (interaciones entre componentes) y datos de probabilidad condicional (provenientes de talleres con expertos). Para cada nodo que tiene padres (nodos condicionales), construye una Tabla de Probabilidad Condicional (CPT) completa. Las CPTs generadas se escriben nuevamente en el mismo archivo Excel, como nuevas hojas denominadas "CPT_<nodo>".

* [2_BBN_Construction_FibrasII.R](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/blob/583a68c41939d851cd99f7c4978d52d73b3eb63b/Scripts/2_BBN_Construction_FibrasII.R): construye la red apartir de un libro de excel, la ajusta con las distribuciones proporcionadas, visualiza el grafico de nodos, arcos y barras de probabilidad, exporta la red al formato Netica (.net) y proporciona una función para inferencia diagnóstica mediante simulacion de escenarios.

## Archivos necesarios
Para esta rutina se necesita 2 archivos principales que son nombrados en el código de la siguiente manera:
```R

# INSUMOS BASE Y RUTAS DE DATOS

# 1. Directorio de trabajo
setwd('C:/Humboldt_2026/FIBRAS2')

# 2. Archivo principal de la red Bayesiana
#    Excel con nodos, arcos y datos de probabilidad condicional
main.excel.path <- "Pruebas/BN_FibrasIIv3.xlsx"
# Hojas requeridas: Nodos, Arcs, Probs, CPT_<nodo>

# 3. Archivo de línea base
#    Excel con probabilidades iniciales para nodos marginales
baseline.path <- "linea_basePC/LineaBase_2020.xlsx"
# Columnas requeridas: Nodos, Probabilidad
```
Para ingresar las tablas de excel correctamente use como plantilla y ejemplo los archivos cargados en la carpeta [Insumos](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/tree/88efe5d36eb38d0170261478d2eef777bd4d37cf/Insumos)


## Funciones principales 

| Comando | Descripción | Script |
| :--- | :--- | :--- |
| `expand.grid`| Crea una tabla de datos a partir de todas las combinaciones de los factores (estados de los nodos) proporcionados| 1_CPT_Generation_FibrasII.R|
| `get_prob_data` |Filtra el la hoja de excel 'probs' y devuelve una lista con: score (probabilidad numérica), estado.p (estado del predictor o nodo padre), estado.r (estado de la respuesta o nodo hijo), estado.int.p (estado intermedio del predictor, si aplica) y estado.int.r (estado intermedio de la respuesta, si aplica)|   1_CPT_Generation_FibrasII.R |
|  |  |  |
| |  |   |
|  |  |  |


---

## Visualización de resultados






# Errores comunes

🚨Paquetes no instalados o conflictos entre versiones.

📁 Archivos de entrada no encontrados o rutas incorrectas.

💾 Agotamiento de memoria o fallos en procesamiento paralelo: El número de workers (núcleos) utilizados, es de los factores más comunes de error en la rutina. Se recomienda hacer pruebas experimentales para encontrar el número que más se ajuste a la memoría disponible en el computador. Se recomienda usar entre 6 y 8 workers si el computador lo permite.


# Autores(as) y contacto
* **[Elkin Alexi Noguera Urbano](https://github.com/elkalexno)** - *Investigador Titular. I. Humboldt* -  Contacto: enoguera@humboldt.org.co
* Maria Alejandra Molina Berbeo  *Investigador Asistente. I. Humboldt* - Contacto: mmolina@humboldt.org.co 
* Jessica Sanchez Londoño *Investigador Asistente. I. Humboldt* - Contacto: jessanchez@humboldt.org.co 
* **[Edwin Uribe Velasquez](https://github.com/edwinuribeecobio)** - *Investigador Asistente. I. Humboldt* - Contacto: euribe@humboldt.org.co

## Licencia

Este proyecto está licenciado bajo la licencia MIT. Para obtener más información, consulte el archivo [LICENCIA](https://github.com/PEM-Humboldt/singularidad-m1-2023/blob/5775e9725df540cf04fb170b167f19b88f00bedf/LICENSE). 



# Referencias Técnicas

Funciones de referencia: https://www.bnlearn.com/

Sofwares de referencia y tutoriales:  https://www.norsys.com/index.html

# Referencias teóricas




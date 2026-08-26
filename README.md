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

En la **primera fase** (creación del modelo conceptual), los investigadores deben definir conceptualmente la estructura del modelo: qué componentes abarca y cómo son las interacciones entre ellos. Es fundamental que el modelo se desarrolle en co-creación con el conocimiento de múltiples expertos, para lograr una versión más integral de las dinámicas del modelo. Técnicamente, en esta fase no se contemplan flujos de trabajo basados en código, sino talleres participativos guiados por metodologías de co-diseño y co-creación.

Los scripts documentados en este repositorio se centran principalmente en la **segunda fase** ("Implementación de Bayesian Belief Networks"), que se encarga de traducir el modelo conceptual a un archivo nativo de redes bayesianas con extensión `.net`. Este formato es compatible con la gran mayoría de los software comerciales y de libre acceso especializados en este tipo de redes.

![Image](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/blob/442a42726c15975667b7eeff6dad6ef8906f1a6e/Imagenes/Flujo_metodologico.png)

## Ejecución del algoritmo
En la carpta de **[Scripst](https://github.com/PEM-Humboldt/bayesian-networks-scenarios/tree/f5dac509bc4f5c2c6dae2eaacf237c8bdffeee08/Scripts)** de este repositorio 


## Archivos necesarios
Para esta rutina se necesita al menos 4 archivos principales que son nombrados en el código de la siguiente manera:
```R
# INSUMOS BASE Y RUTAS DE DATOS --------------------------------------------



```
## Problema de optimización



| Componente | Descripción | Comando |
| :--- | :--- | :--- |
| | | |
|  | |  |
|  |  |  |
| |  |   |
|  |  |  |


---

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




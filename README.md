(EN CONSTRUCCIÓN)

# 🚦 Creación de escenarios de Redes de Creencia Bayesiana para la toma de decisiones

Los Escenarios de Naturaleza a partir del marco de trabajo de TNFD (Taskforce on Nature-related Financial Disclosures) permiten simular transformaciones críticas en el estado de los impactos, dependecias y riesgos empresariales en relación al estado de la biodiversidad y la naturaleza. Bajo este enfoque sistémico, la integración de las presiones de un clima cambiante, el aumento de la presión de las actividades humanas y las transiciones del entorno natural en una mismo modelo, fomenta decisiones informadas que aseguran en conjunto la protección de los ecosistemas y la continuidad empresarial a largo plazo.

En este repositorio se compilan las rutinas para la generación de Redes Bayesianas con base en el marco del proyecto Fibras II con participación del IAVH y Ecopetrol. En este flujos de trabajo se propuso conectar TNFD y "Posriteve Nature" que son dos marcos crucialaes para que los negocios y mercados estén alienados con la conservación de la Naturaleza.



# Dependencias
* [R](https://cran.r-project.org/mirrors.html)

# Prerequisitos
El paquete [bnlearn](https://www.bnlearn.com/) permite ejecutar las funciones más importantes para la contrucción de redes bayesianas a partir de evidencia y conocimeinto de experto.
```R
# Instalación


# Librerias necesarias


# Versiones utilizadas



```
---
# Descripción flujo de análisis




## Ejecución del algoritmo
Específicamente la etapa cuatro del flujo de análisis comprende las funciones principales para el desarrollo del algoritmo de priorización, en esta fase se generan 60 portafolios que resultan de la combinación de metas de conservación (10-100%) y factores de penalidad (0-100) Por la complejidad de las combinaciónes entre estas variables de análisis, se utilizó una estructura paralelizada (paquetes `furr`, `future` y `future.apply`) que ayudan a reducir significativamente los tiempos de ejecución. Este repositorio contiene sola una version para la ejecución del algoritmo: 

* Costos por conectividad: PrioritizR_Run_SingularidadM1_acuatica.R


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




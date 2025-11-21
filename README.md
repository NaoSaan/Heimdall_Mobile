Pasos para trabajarcon ramas

Si estas trabajando en tu rama y debes traer codigo de main hacerlo siguiente:

En tu rama:

- Git status
- Git add .
- Git commit -m "Mensaje de commit"
- Git push origin <nombre-de-tu-rama>

Pasar a la rama de Main:

- Git checkout main
- Git pull main
- Git merge <nombre-de-tu-rama>
- Git push origin main

Regresar a tu rama:

- Git checkout <nombre-de-tu-rama>
- Git merge main
- Git push origin <nombre-de-tu-rama>

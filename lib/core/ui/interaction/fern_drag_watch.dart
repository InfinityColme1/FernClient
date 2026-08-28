import 'package:flutter/widgets.dart';

/// Si lo que se esta arrastrando esta ahora mismo sobre un sitio donde se puede
/// soltar.
///
/// **Por que es un aviso suelto y no un parametro.** Lo que va pegado al cursor
/// lo pinta `Draggable` en la capa de encima, fuera del arbol de quien lo
/// arrastra y fuera del arbol de quien lo va a recoger. Ninguno de los dos puede
/// pasarle nada al otro por el camino normal, y sin embargo la miniatura tiene
/// que enterarse de que ha llegado a una etiqueta para encoger y oscurecerse.
///
/// Solo hay un arrastre a la vez, asi que un solo aviso basta.
final ValueNotifier<bool> fernDragIsOverTarget = ValueNotifier<bool>(false);

/// Lo que va pegado al cursor en el arrastre que este en marcha.
///
/// Se guarda para poder **volver a pintarlo despues de soltar**: la animacion de
/// que el contenido entra dentro de la etiqueta necesita saber que se ha soltado,
/// y quien recoge solo recibe una lista de identificadores. La miniatura ya
/// existe y la construye quien arrastra, asi que se apunta aqui en vez de armar
/// otra desde cero con datos que la fila que recoge no tiene.
///
/// Vale `null` cuando no hay nada arrastrandose.
final ValueNotifier<Widget?> fernDragPreview = ValueNotifier<Widget?>(null);

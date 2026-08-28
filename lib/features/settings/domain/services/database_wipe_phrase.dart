/// Si lo escrito autoriza a vaciar la base de datos.
///
/// Vaciarla no se puede deshacer y no hay copia de seguridad de la que tirar:
/// se van las etiquetas, los creadores, los fernies, los modelos y las regiones
/// marcadas una a una. Un botón, por escondido que esté, se pulsa sin querer;
/// escribir la frase entera, no.
///
/// Se compara **exactamente**, salvo los espacios de los lados: aceptar
/// mayúsculas y minúsculas indistintamente convertiría el trámite en teclear
/// cualquier cosa parecida, que es justo lo que esto existe para impedir.
bool isDatabaseWipeConfirmed({required String typed, required String phrase}) {
  final expected = phrase.trim();

  return expected.isNotEmpty && typed.trim() == expected;
}

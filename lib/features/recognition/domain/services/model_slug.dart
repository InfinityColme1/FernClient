/// El nombre de un modelo, apto para una carpeta y para un `data.yaml`.
///
/// Lo lee Python y acaba siendo nombre de fichero: acentos, espacios y barras
/// dan problemas en un sitio o en el otro.
///
/// Vive aquí y no en quien lo usa porque lo usan tres: el que monta el dataset,
/// el que trae unos pesos de fuera y el que borra lo que dejaron. **Tienen que
/// dar exactamente lo mismo**: si uno escribe `personajes-de-miraculous` y otro
/// busca `personajes_de_miraculous`, lo que se borra no es lo que se escribió y
/// la carpeta se queda ahí para siempre.
String modelSlug(String name) {
  const accents = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
    'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u', 'ç': 'c',
  };

  final buffer = StringBuffer();

  for (final rune in name.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final plain = accents[char] ?? char;

    if (RegExp(r'[a-z0-9]').hasMatch(plain)) {
      buffer.write(plain);
    } else if (buffer.isNotEmpty && !buffer.toString().endsWith('-')) {
      buffer.write('-');
    }
  }

  final slug = buffer.toString().replaceAll(RegExp(r'-+$'), '');

  return slug.isEmpty ? 'modelo' : slug;
}

/// Cómo se llama la carpeta de un modelo, dentro de datasets o de runs.
///
/// Con el identificador delante porque dos modelos se pueden llamar igual, y
/// porque es lo que permite reconocer la carpeta de uno aunque le hayan cambiado
/// el nombre después.
String modelFolderName({required int id, required String name}) =>
    '$id-${modelSlug(name)}';

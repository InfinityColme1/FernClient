/// El peso de un fichero escrito para que se pueda leer de un vistazo.
///
/// Se usa para comparar dos copias del mismo contenido, así que lo que importa
/// es que la diferencia salte a la vista: «2,4 MB» al lado de «890 KB» se
/// compara solo, y «2411724 B» al lado de «911360 B» hay que contarlo con el
/// dedo.
///
/// Un decimal y no más: el segundo no cambia ninguna decisión y alarga la línea
/// justo donde hay dos columnas peleándose por el ancho.
String formatFileWeight(int? bytes) {
  if (bytes == null || bytes < 0) return '';
  if (bytes < 1024) return '$bytes B';

  const units = ['KB', 'MB', 'GB', 'TB'];

  var value = bytes / 1024;
  var unit = 0;

  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }

  // Sin decimal a partir de cien: tres cifras ya dicen de qué tamaño es, y el
  // «102,4» no aporta nada que «102» no diga.
  final text = value >= 100
      ? value.round().toString()
      : value.toStringAsFixed(1).replaceAll('.', ',');

  return '$text ${units[unit]}';
}

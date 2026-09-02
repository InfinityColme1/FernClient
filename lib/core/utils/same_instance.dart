/// Una colección que se compara **por identidad** en vez de por dentro.
///
/// Existe para las listas grandes de los estados. Un bloc mira si el estado
/// nuevo es igual al anterior antes de emitirlo, y Equatable compara las listas
/// elemento a elemento: con veinte mil contenidos, cada cambio de estado —marcar
/// una celda, pasar el ratón, abrir un panel— recorría veinte mil entidades con
/// sus doce campos cada una. Ahí se iban los fotogramas.
///
/// Es correcto siempre que la colección **no se toque por dentro**: cada cambio
/// construye una nueva y `copyWith` conserva la instancia de lo que no cambia.
/// Y el error posible es benigno: construir una lista nueva con lo mismo dentro
/// provoca una emisión de más —un repintado—, nunca una de menos.
class SameInstance {
  final Object? value;

  const SameInstance(this.value);

  @override
  bool operator ==(Object other) =>
      other is SameInstance && identical(value, other.value);

  @override
  int get hashCode => identityHashCode(value);
}

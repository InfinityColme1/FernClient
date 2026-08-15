/// La señal con la que el usuario para una importación que está en marcha.
///
/// Una importación puede durar mucho (recorre una cuenta entera y se descarga
/// ficheros de internet), así que tiene que poder pararse. No hay forma de
/// cortar por la mitad lo que ya se está descargando, ni falta: lo que se para
/// es lo siguiente, y con eso el usuario deja de esperar en cuanto termine el
/// fichero que estuviera a medias.
///
/// Es una señal compartida y no un método de cada escaneo porque quien la
/// levanta (la pantalla) y quien la mira (el recorrido de las fuentes) no se
/// conocen.
///
/// Lo ya descargado se queda donde está: son ficheros en el equipo y contenidos
/// dados de alta, y pararse a medias no es motivo para tirarlos.
class ImportCancellation {
  bool _isCancelled = false;

  /// El usuario ha pedido parar. Lo miran los recorridos entre contenido y
  /// contenido.
  bool get isCancelled => _isCancelled;

  /// Para lo que esté en marcha.
  void cancel() => _isCancelled = true;

  /// Deja la señal baja. Lo hace quien lanza una importación, para que la
  /// anterior no pare la siguiente.
  void reset() => _isCancelled = false;
}

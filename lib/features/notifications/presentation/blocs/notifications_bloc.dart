import 'dart:async';

import 'package:Fern/features/notifications/data/services/notification_service.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationsEvents extends Equatable {
  const NotificationsEvents();

  @override
  List<Object?> get props => [];
}

/// Han cambiado los contadores. Lo emite el propio bloc al escuchar al servicio.
class NotificationCountsUpdatedEvent extends NotificationsEvents {
  final AppNotificationCounts counts;

  const NotificationCountsUpdatedEvent(this.counts);

  @override
  List<Object?> get props => [counts.byKind];
}

/// El usuario ha llegado a una pantalla, así que lo que llevaba allí ya está
/// visto.
class RouteSeenEvent extends NotificationsEvents {
  final String route;

  const RouteSeenEvent(this.route);

  @override
  List<Object?> get props => [route];
}

class NotificationsState extends Equatable {
  final AppNotificationCounts counts;

  const NotificationsState({this.counts = AppNotificationCounts.empty});

  /// Cuántos avisos hay pendientes en una pantalla del menú.
  int badgeFor(String route) => counts.forRoute(route);

  @override
  List<Object?> get props => [counts.byKind];
}

/// Lo que la interfaz sabe de los avisos pendientes.
///
/// Único, como el de ajustes y el de trabajos: los contadores se pintan en el
/// menú lateral, que está en el marco de la aplicación y no en una pantalla.
class NotificationsBloc extends Bloc<NotificationsEvents, NotificationsState> {
  final NotificationService _service;
  StreamSubscription<AppNotificationCounts>? _subscription;

  NotificationsBloc({required NotificationService service})
      : _service = service,
        super(NotificationsState(counts: service.counts)) {
    on<NotificationCountsUpdatedEvent>(
      (event, emit) => emit(NotificationsState(counts: event.counts)),
    );
    on<RouteSeenEvent>((event, emit) => _service.markRouteSeen(event.route));

    _subscription = _service.changes
        .listen((counts) => add(NotificationCountsUpdatedEvent(counts)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();

    return super.close();
  }
}

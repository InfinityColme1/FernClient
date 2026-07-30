

abstract class DataState<T> {
  final T ? data;
  final Exception ? exception;

  const DataState({this.data, this.exception});
}


class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}


class DataException<T> extends DataState<T> {
  const DataException(Exception exception) : super(exception: exception);
}
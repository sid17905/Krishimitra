/// A tiny, dependency-free "state machine" used across the app to model the
/// three UI states every async/API call moves through: loading, success, error.
///
/// Screens switch on the concrete subtype to decide what to render
/// (shimmer, data, or an error card with a retry button).
library;

/// Base sealed-style class. `sealed` lets the analyzer force exhaustive
/// handling in `switch` expressions so a screen can never forget a state.
sealed class ResultState<T> {
  const ResultState();
}

/// Emitted the moment a request starts. Screens show a shimmer / spinner.
class LoadingState<T> extends ResultState<T> {
  const LoadingState();
}

/// Emitted on a successful response. Carries the decoded data.
class SuccessState<T> extends ResultState<T> {
  final T data;
  const SuccessState(this.data);
}

/// Emitted on any failure (network, timeout, parse, non-200).
/// [message] is user-facing; [isTimeout] lets the UI tailor the copy.
class ErrorState<T> extends ResultState<T> {
  final String message;
  final bool isTimeout;
  const ErrorState(this.message, {this.isTimeout = false});
}

/// Convenience helpers so widgets can read state without a full switch.
extension ResultStateX<T> on ResultState<T> {
  bool get isLoading => this is LoadingState<T>;
  bool get isSuccess => this is SuccessState<T>;
  bool get isError => this is ErrorState<T>;

  /// Null-safe access to the data (null unless in a success state).
  T? get dataOrNull => this is SuccessState<T> ? (this as SuccessState<T>).data : null;
}

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

/// Waits until events stop arriving for [duration], then handles only the
/// latest one, cancelling any handler still running for a previous event.
EventTransformer<E> debounceRestartable<E>(Duration duration) =>
    (events, mapper) =>
        restartable<E>().call(events.debounce(duration), mapper);

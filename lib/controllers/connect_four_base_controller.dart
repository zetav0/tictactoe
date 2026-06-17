import 'base_controller.dart';

/// Extends BaseGameController with the two extra fields the Connect Four
/// board widget needs to drive drop and win animations.
abstract class ConnectFourBaseController extends BaseGameController {
  int? get lastPlacedIndex;
  int get moveCount;
}

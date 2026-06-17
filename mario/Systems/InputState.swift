import CoreGraphics

/// Trạng thái input thuần dữ liệu, tách rời nguồn input (touch / gamepad sau này).
/// TouchControls emit ra struct này, Player tiêu thụ.
struct InputState: Equatable {
    var leftPressed = false
    var rightPressed = false
    /// True khi nút jump đang được giữ. Player tự detect cạnh lên (rising edge).
    var jumpHeld = false

    /// -1 (trái), 0 (đứng yên), +1 (phải). Giữ cả 2 nút → đứng yên.
    var horizontal: CGFloat {
        (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0)
    }
}

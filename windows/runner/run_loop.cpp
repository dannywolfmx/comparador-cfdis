#include "run_loop.h"

#include <windows.h>

#include <algorithm>

RunLoop::RunLoop() {}

RunLoop::~RunLoop() {}

void RunLoop::Run() {
  bool keep_running = true;
  TimePoint next_flutter_event_time = TimePoint::clock::now();
  while (keep_running) {
    std::chrono::nanoseconds wait_duration =
        std::max(std::chrono::nanoseconds(0),
                 next_flutter_event_time - TimePoint::clock::now());
    ::MsgWaitForMultipleObjects(
        0, nullptr, FALSE, static_cast<DWORD>(wait_duration.count() / 1000000),
        QS_ALLINPUT);
    bool processed_events = false;
    MSG message;
    // Procesamos todos los mensajes de Windows disponibles.
    while (::PeekMessage(&message, nullptr, 0, 0, PM_REMOVE)) {
      processed_events = true;
      if (message.message == WM_QUIT) {
        keep_running = false;
        break;
      }
      ::TranslateMessage(&message);
      ::DispatchMessage(&message);
    }
    // Permitir que los motores de Flutter procesen eventos.
    if (processed_events) {
      next_flutter_event_time =
          std::min(next_flutter_event_time, TimePoint::clock::now());
    }
    next_flutter_event_time = engine_->ProcessMessages();
  }
}

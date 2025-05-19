// timer.js
"use strict";

// Timer variables
const timerDuration = 600; // total time in seconds. Change as needed.
let remainingTime   = timerDuration;
let timerInterval   = null;

// Helper: formats seconds → MM:SS
function formatTime(seconds) {
  const minutes    = Math.floor(seconds / 60);
  const secs       = seconds % 60;
  const minStr     = minutes < 10 ? "0" + minutes : minutes;
  const secStr     = secs    < 10 ? "0" + secs    : secs;
  return minStr + ":" + secStr;
}

// Update the on-page display
function updateDisplay() {
  document.getElementById("timer-display").textContent = formatTime(remainingTime);
}

// START the timer (and POST a “start” event)
async function startTimer() {
  if (timerInterval !== null) return;       // already running
  // tell Sinatra “I’m starting now”
  await fetch("/timer/start", { method: "POST" });
  // then kick off your countdown…
  timerInterval = setInterval(() => {
    if (remainingTime > 0) {
      remainingTime--;
      updateDisplay();
    } else {
      stopTimer();                          // auto-stop at zero
      alert("Time's up!");
    }
  }, 1000);
}

// STOP the timer (and POST a “stop” event)
async function stopTimer() {
  if (timerInterval === null) return;       // not running
  clearInterval(timerInterval);
  timerInterval = null;
  // tell Sinatra “I’ve stopped now”
  await fetch("/timer/stop", { method: "POST" });
}

// RESET the timer (and if it was running, also record a stop)
async function resetTimer() {
  if (timerInterval !== null) {
    await stopTimer();
  }
  remainingTime = timerDuration;
  updateDisplay();
}

// wire up your buttons
document.addEventListener("DOMContentLoaded", () => {
  updateDisplay();

  document.getElementById("startTimer").addEventListener("click", startTimer);
  document.getElementById("stopTimer" ).addEventListener("click", stopTimer);
  document.getElementById("resetTimer").addEventListener("click", resetTimer);
});

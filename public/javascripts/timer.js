"use strict";

// Timer variables
var timerDuration = 600; // total time in seconds. Change as needed.
var remainingTime = timerDuration;
var timerInterval = null;

// Helper function: formats the time (in seconds) to MM:SS.
function formatTime(seconds) {
  var minutes = Math.floor(seconds / 60);
  var secs = seconds % 60;
  // Format with leading zeros for single-digit values.
  var minutesStr = minutes < 10 ? "0" + minutes : minutes;
  var secondsStr = secs < 10 ? "0" + secs : secs;
  return minutesStr + ":" + secondsStr;
}

// Function to update the display with the current remaining time
function updateDisplay() {
  document.getElementById("timer-display").textContent = formatTime(remainingTime);
}

// Function to start the timer
function startTimer() {
  // Prevent multiple intervals from running simultaneously.
  if (timerInterval !== null) return;

  timerInterval = setInterval(function() {
    if (remainingTime > 0) {
      remainingTime--;
      updateDisplay();
    } else {
      stopTimer(); // Automatically stop when the timer hits 0.
      alert("Time's up!");
    }
  }, 1000);
}

// Function to stop the timer
function stopTimer() {
  clearInterval(timerInterval);
  timerInterval = null;
}

// Function to reset the timer
function resetTimer() {
  stopTimer();
  remainingTime = timerDuration;
  updateDisplay();
}

// Attach event listeners to the buttons once the document is loaded
document.addEventListener("DOMContentLoaded", function() {
  // Update the initial display
  updateDisplay();

  var startButton = document.getElementById("startTimer");
  var stopButton = document.getElementById("stopTimer");
  var resetButton = document.getElementById("resetTimer");

  startButton.addEventListener("click", startTimer);
  stopButton.addEventListener("click", stopTimer);
  resetButton.addEventListener("click", resetTimer);
});

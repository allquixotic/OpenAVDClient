function isWindowReadyForInput(win) {
  return Boolean(win && !win.isDestroyed() && win.isVisible() && win.isFocused());
}

function isSystemKey(input) {
  const systemKeys = ['Super', 'Meta', 'Alt', 'Tab', 'Escape'];
  return Boolean(systemKeys.includes(input.key) ||
         (input.alt && input.key === 'Tab') ||
         (input.meta && input.key !== 'F11' && input.key !== 'F12'));
}

function getFocusedInputAction(input, options = {}) {
  if (input.type !== 'keyDown') {
    return 'ignore';
  }

  if (input.key === 'F11') {
    return 'toggle-fullscreen';
  }

  if (input.key === 'F12') {
    return 'toggle-devtools';
  }

  if (options.allowForceClose && (input.control || input.meta) && (input.key === 'W' || input.key === 'Q')) {
    return 'force-close';
  }

  return 'allow';
}

module.exports = {
  getFocusedInputAction,
  isSystemKey,
  isWindowReadyForInput
};

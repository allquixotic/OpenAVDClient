const test = require('node:test');
const assert = require('node:assert/strict');
const {
  getFocusedInputAction,
  isSystemKey,
  isWindowReadyForInput
} = require('../src/input-guard');

function mockWindow({ destroyed = false, visible = true, focused = true } = {}) {
  return {
    isDestroyed: () => destroyed,
    isVisible: () => visible,
    isFocused: () => focused
  };
}

test('window must be alive, visible, and focused for input', () => {
  assert.equal(isWindowReadyForInput(mockWindow()), true);
  assert.equal(isWindowReadyForInput(mockWindow({ destroyed: true })), false);
  assert.equal(isWindowReadyForInput(mockWindow({ visible: false })), false);
  assert.equal(isWindowReadyForInput(mockWindow({ focused: false })), false);
  assert.equal(isWindowReadyForInput(null), false);
});

test('system key detection covers OS-level navigation keys', () => {
  assert.equal(isSystemKey({ key: 'Tab', alt: true }), true);
  assert.equal(isSystemKey({ key: 'A', meta: true }), true);
  assert.equal(isSystemKey({ key: 'F11', meta: true }), false);
  assert.equal(isSystemKey({ key: 'A' }), false);
});

test('focused input action only handles explicit app shortcuts', () => {
  assert.equal(getFocusedInputAction({ type: 'keyUp', key: 'F11' }), 'ignore');
  assert.equal(getFocusedInputAction({ type: 'keyDown', key: 'F11' }), 'toggle-fullscreen');
  assert.equal(getFocusedInputAction({ type: 'keyDown', key: 'F12' }), 'toggle-devtools');
  assert.equal(getFocusedInputAction({ type: 'keyDown', key: 'W', control: true }), 'allow');
  assert.equal(getFocusedInputAction({ type: 'keyDown', key: 'W', control: true }, { allowForceClose: true }), 'force-close');
  assert.equal(getFocusedInputAction({ type: 'keyDown', key: 'A' }), 'allow');
});

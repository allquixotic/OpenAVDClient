const test = require('node:test');
const assert = require('node:assert/strict');
const {
  APP_DESCRIPTION,
  APP_DISPLAY_NAME,
  APP_LONG_NAME,
  DEFAULT_CLIENT_HINT_HEADERS,
  DEFAULT_CONNECTION_URL,
  DEFAULT_USER_AGENT
} = require('../src/app-metadata');

test('app metadata exposes OpenAVDClient branding', () => {
  assert.equal(APP_DISPLAY_NAME, 'OpenAVDClient');
  assert.equal(APP_LONG_NAME, 'Open Azure Virtual Desktop Client');
  assert.match(APP_DESCRIPTION, /Azure Virtual Desktop/);
  assert.equal(DEFAULT_CONNECTION_URL, 'https://windows.cloud.microsoft/#/devices');
});

test('default Edge profile matches Windows x64 Edge 147', () => {
  assert.match(DEFAULT_USER_AGENT, /Windows NT 10\.0; Win64; x64/);
  assert.match(DEFAULT_USER_AGENT, /Chrome\/147\.0\.0\.0/);
  assert.match(DEFAULT_USER_AGENT, /Edg\/147\.0\.3912\.60/);
  assert.equal(DEFAULT_CLIENT_HINT_HEADERS['Sec-CH-UA-Platform'], '"Windows"');
  assert.equal(DEFAULT_CLIENT_HINT_HEADERS['Sec-CH-UA-Bitness'], '"64"');
});

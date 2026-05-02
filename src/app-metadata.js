const APP_DISPLAY_NAME = 'OpenAVDClient';
const APP_LONG_NAME = 'Open Azure Virtual Desktop Client';
const APP_DESCRIPTION = 'Open Azure Virtual Desktop Client - an unofficial standalone Electron client for Azure Virtual Desktop web access.';
const DEFAULT_CONNECTION_URL = 'https://windows.cloud.microsoft/#/devices';

// Current common Microsoft Edge Stable user agent for 64-bit Windows desktop.
// Windows 11 intentionally still reports Windows NT 10.0 in Chromium-family user-agent strings.
const DEFAULT_USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.3912.60';

// Client hints align the reduced/frozen User-Agent string with a Windows 11 x64 Edge profile.
const DEFAULT_CLIENT_HINT_HEADERS = Object.freeze({
  'Sec-CH-UA': '"Microsoft Edge";v="147", "Chromium";v="147", "Not_A Brand";v="8"',
  'Sec-CH-UA-Mobile': '?0',
  'Sec-CH-UA-Platform': '"Windows"',
  'Sec-CH-UA-Platform-Version': '"15.0.0"',
  'Sec-CH-UA-Arch': '"x86"',
  'Sec-CH-UA-Bitness': '"64"'
});

module.exports = {
  APP_DESCRIPTION,
  APP_DISPLAY_NAME,
  APP_LONG_NAME,
  DEFAULT_CLIENT_HINT_HEADERS,
  DEFAULT_CONNECTION_URL,
  DEFAULT_USER_AGENT
};

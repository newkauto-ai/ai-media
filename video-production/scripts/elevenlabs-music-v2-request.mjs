import { writeFile } from 'node:fs/promises';

const apiKey = process.env.ELEVENLABS_MUSIC_API_KEY;
const outputPath = process.env.ELEVENLABS_MUSIC_OUTPUT;
const metadataPath = process.env.ELEVENLABS_MUSIC_METADATA_OUTPUT;
const payload = process.env.ELEVENLABS_MUSIC_PAYLOAD;
const endpoint = process.env.ELEVENLABS_MUSIC_ENDPOINT;

if (!apiKey || !outputPath || !metadataPath || !payload || !endpoint) {
  console.error('ElevenLabs Music request helper is missing required process configuration.');
  process.exitCode = 2;
} else {
  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'xi-api-key': apiKey,
      },
      body: payload,
    });
    const bytes = new Uint8Array(await response.arrayBuffer());
    if (!response.ok) {
      const message = new TextDecoder().decode(bytes).slice(0, 1000);
      console.error(`ElevenLabs Music HTTP ${response.status}: ${message}`);
      process.exitCode = 1;
    } else if (bytes.length === 0) {
      console.error('ElevenLabs Music returned an empty audio response.');
      process.exitCode = 1;
    } else {
      const contentType = response.headers.get('content-type') || '';
      if (!contentType.includes('audio') && !contentType.includes('octet-stream')) {
        console.error(`ElevenLabs Music returned an unexpected success content type: ${contentType || 'missing'}`);
        process.exitCode = 1;
      } else {
        await writeFile(outputPath, bytes);
        await writeFile(metadataPath, JSON.stringify({
          provider: 'elevenlabs_music',
          endpoint,
          content_type: contentType,
          provider_song_id: response.headers.get('song-id'),
          provider_request_id: response.headers.get('request-id'),
          downloaded_bytes: bytes.length,
        }, null, 2));
        process.stdout.write(`content_type=${contentType}; song_id=${response.headers.get('song-id') || 'unknown'}\n`);
      }
    }
  } catch (error) {
    console.error(`ElevenLabs Music request failed: ${error.message}`);
    process.exitCode = 1;
  }
}

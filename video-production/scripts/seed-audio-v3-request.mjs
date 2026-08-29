import { writeFile } from 'node:fs/promises';

const apiKey = process.env.VOLCENGINE_SEED_AUDIO_API_KEY;
const outputPath = process.env.VOLCENGINE_SEED_AUDIO_OUTPUT;
const payload = process.env.VOLCENGINE_SEED_AUDIO_PAYLOAD;
const endpoint = process.env.VOLCENGINE_SEED_AUDIO_ENDPOINT;

if (!apiKey || !outputPath || !payload || !endpoint) {
  console.error('Seed Audio request helper is missing required process configuration.');
  process.exitCode = 2;
} else {
  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': apiKey,
      },
      body: payload,
    });
    const bytes = new Uint8Array(await response.arrayBuffer());
    if (!response.ok) {
      const message = new TextDecoder().decode(bytes).slice(0, 1000);
      console.error(`Seed Audio HTTP ${response.status}: ${message}`);
      process.exitCode = 1;
    } else {
      const contentType = response.headers.get('content-type') || '';
      const looksLikeMp3 = bytes.length >= 3 && ((bytes[0] === 0x49 && bytes[1] === 0x44 && bytes[2] === 0x33) || (bytes[0] === 0xff && (bytes[1] & 0xe0) === 0xe0));
      if (contentType.includes('audio') || looksLikeMp3) {
        await writeFile(outputPath, bytes);
        process.stdout.write(`content_type=${contentType}\n`);
      } else {
        let result;
        try {
          result = JSON.parse(new TextDecoder().decode(bytes));
        } catch {
          result = null;
        }
        if (!result || typeof result.audio !== 'string' || result.audio.length === 0) {
          const keys = result && typeof result === 'object' ? Object.keys(result).join(',') : 'unparseable';
          console.error(`Seed Audio returned a success response without inline audio. fields=${keys}`);
          process.exitCode = 1;
        } else {
          const audioBytes = Buffer.from(result.audio, 'base64');
          if (audioBytes.length === 0) {
            console.error('Seed Audio returned an empty Base64 audio payload.');
            process.exitCode = 1;
          } else {
            await writeFile(outputPath, audioBytes);
            process.stdout.write(`content_type=${contentType}; provider_duration=${result.duration ?? 'unknown'}; original_duration=${result.original_duration ?? 'unknown'}\n`);
          }
        }
      }
    }
  } catch (error) {
    console.error(`Seed Audio request failed: ${error.message}`);
    process.exitCode = 1;
  }
}

const method = process.env.VOLCENGINE_HTTP_METHOD;
const uri = process.env.VOLCENGINE_HTTP_URI;
const authorization = process.env.VOLCENGINE_HTTP_AUTHORIZATION;
const resourceId = process.env.VOLCENGINE_HTTP_RESOURCE_ID;
const body = process.env.VOLCENGINE_HTTP_BODY;

if (!method || !uri || !authorization || !resourceId) {
  console.error('Volcengine request helper is missing required process configuration.');
  process.exit(2);
}

const headers = {
  Authorization: authorization,
  'Resource-Id': resourceId,
};
if (body) headers['Content-Type'] = 'application/json';

try {
  const response = await fetch(uri, {
    method,
    headers,
    body: method === 'GET' ? undefined : body,
  });
  const content = await response.text();
  if (!response.ok) {
    console.error(`Volcengine HTTP ${response.status}: ${content}`);
    process.exitCode = 1;
  } else {
    process.stdout.write(content);
  }
} catch (error) {
  console.error(`Volcengine request failed: ${error.message}`);
  process.exitCode = 1;
}

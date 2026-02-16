
import createApp from './app';

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === '/health') {
      return new Response('OK');
    }

    // Body handling
    let body = {};
    if (['POST', 'PUT', 'PATCH'].includes(request.method)) {
      const contentType = request.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        try {
          body = await request.json();
        } catch (e) {
          // ignore
        }
      }
    }

    return new Promise((resolve) => {
      const app = createApp(env);

      const req = {
        method: request.method,
        url: url.pathname,
        query: Object.fromEntries(url.searchParams),
        env: env,
        body: body,
        headers: Object.fromEntries(request.headers),
        user: null // for auth middleware
      };

      const res = {
        _statusCode: 200,
        _headers: {},

        status(code) {
          this._statusCode = code;
          return this;
        },

        json(data) {
          this._headers['Content-Type'] = 'application/json';
          resolve(new Response(JSON.stringify(data), {
            status: this._statusCode,
            headers: this._headers
          }));
        },

        send(data) {
          resolve(new Response(data, {
            status: this._statusCode,
            headers: this._headers
          }));
        },

        // Basic header support
        setHeader(key, value) {
          this._headers[key] = value;
          return this;
        }
      };

      try {
        app(req, res);
      } catch (e) {
        resolve(new Response('App Error: ' + e.message + '\n' + e.stack, { status: 500 }));
      }
    });
  }
};

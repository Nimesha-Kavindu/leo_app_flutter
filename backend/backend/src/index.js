
const createApp = require('./app');

export default {
  async fetch(request, env, ctx) {
    const app = createApp(env);

    const url = new URL(request.url);
    
    // Create a mock Request object for Express
    // Note: This is a minimal adapter. For production, consider using a library like 'wouter' or 'hono' if Express is too heavy,
    // or a robust adapter library.
    
    const req = {
      method: request.method,
      url: url.pathname + url.search,
      path: url.pathname,
      query: Object.fromEntries(url.searchParams),
      headers: Object.fromEntries(request.headers),
      body: {}, // Body parsing is handled below or by express.json()
      env: env
    };

    // Body handling
    if (['POST', 'PUT', 'PATCH'].includes(request.method)) {
      try {
        const contentType = request.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
            req.body = await request.json();
        } else {
            req.body = await request.text();
        }
      } catch (e) {
        req.body = {};
      }
    }

    // Create a mock Response object and a Promise to wait for the Express response
    return new Promise((resolve) => {
      const res = {
        _headers: {},
        _statusCode: 200,
        _body: null,
        
        status(code) {
          this._statusCode = code;
          return this;
        },
        
        set(key, value) {
          this._headers[key] = value;
          return this;
        },

        header(key, value) {
            return this.set(key, value);
        },
        
        json(data) {
          this._headers['Content-Type'] = 'application/json';
          this._body = JSON.stringify(data);
          this.end();
        },
        
        send(data) {
           this._body = data;
           this.end();
        },
        
        end() {
          resolve(new Response(this._body, {
            status: this._statusCode,
            headers: this._headers
          }));
        }
      };

      // Call the Express app
      app(req, res);
    });
  }
};

# tyk-kc-demo

This is a super simple demo showing how to use [Tyk](https://tyk.io) to protect an API (here just https://httpbin.org),
blocking requests as unauthorized unless accompanied by an OIDC token from a Keycloak instance.

For convenience, add the following lines to your `/etc/hosts`:

```
127.0.0.1       oidc
127.0.0.1       tyk
```

Then fire everything up - currently that's the OIDC IdP (Keycloak) and Tyk:

```
docker-compose up -d
```

When keycloak is up and running (when `docker-compose logs oidc` shows `Admin console listening` - you can wait or
you can run `./oidc/wait_keycloak.sh`), add the users and realm by running `./oidc/config-oidc-service`.  (That
will take 20 seconds or so).  The keycloak will then be configured with two users (user1 and user2), 
with passwords pass1 and pass2.

Tyk here is configured with exactly one api, `http://tyk:8000/test-api` which just redirects to httpbin.   If you try accessing
it without a token, you will be sorely dissapointed and get a 401 error:

```
curl http://tyk:8000/test-api/get

{
    "error": "Key not authorised"
}
```

If you have a token, however, all works.  Here we're getting one by using the client credentials flow which
isn't how we'd actually get the token, but:

```
TOKEN1=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )
curl -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Authorization": "Bearer eyJhbGciOiJ[...]6oSgYwV2m-g",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.64.1",
    "X-Amzn-Trace-Id": "Root=1-60d245a2-30b49b0e4563478b1fa5091f"
  },
  "origin": "192.168.192.1, 216.181.72.113",
  "url": "http://httpbin.org/get"
}
```

Note a few things here:

* Tyk does not automatically do the OAuth2 dance for you; if you want that you have to implement it yourself in middleware and/or virtual endpoints.  Tyk (like a lot of other API Gateways) assumes that there is a front end to handle that for you, and that its job is to interpose between the front end and the back end.
* Those that will do that dance for you all have pretty hardcoded assumptions that there is exactly one ID provider.
* Tyk Identity Broker's job is to handle auth _for Tyk itself_, like to the dashboard or the developer portal (neither of which are part of the open source release of Tyk).
* Tyk does have OAuth2 handling but that doesn't do the dance, it just has Tyk masquerade as the IdP so that IdPs can change behind the scene without effecting the front end.

{
  "name": "appertura-admin",
  "framework": null,
  "outputDirectory": "build/web",
  "buildCommand": "flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY",
  "installCommand": "flutter pub get",
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "SAMEORIGIN" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" }
      ]
    },
    {
      "source": "/flutter_service_worker.js",
      "headers": [{ "key": "Cache-Control", "value": "no-cache" }]
    }
  ],
  "rewrites": [{ "source": "/((?!api/).*)", "destination": "/index.html" }],
  "regions": ["cdg1", "mad1"]
}

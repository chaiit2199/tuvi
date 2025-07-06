import Config

if config_env() == :prod do

  secret_key_base = System.get_env("SECRET_KEY_BASE") || raise ("No SECRET_KEY_BASE config.")
  api_key_base = System.get_env("API_KEY_GEMINI") || raise ("No API_KEY_GEMINI config.")
  url_gemini = System.get_env("URL_GEMINI") || raise ("No URL_GEMINI config.")
  gemini_crontab = System.get_env("GEMINI_CRONTAB") || raise ("No GEMINI_CRONTAB config.")
  allow_check_origin = System.get_env("ALLOW_CHECK_ORIGIN") || raise ("No ALLOW_CHECK_ORIGIN config.")

  config :tuvi, Tuvi.Repo,
    username: System.get_env("DB_USERNAME") || raise("No DB_USERNAME config."),
    password: System.get_env("DB_PASSWORD") || raise("No DB_PASSWORD config."),
    hostname: System.get_env("DB_HOST") || raise("No DB_HOST config."),
    database: System.get_env("DB") || raise("No DB config."),
    port: System.get_env("DB_PORT") || raise("No DB_PORT config."),
    pool_size:
      String.to_integer(
        System.get_env("DB_POOL_SIZE") || raise("No DB_POOL_SIZE config.")
      ),
    stacktrace: (System.get_env("DB_STACKTRACE") || "false") in ["true"],
    show_sensitive_data_on_connection_error: false,
    log: false

  config :tuvi,
    env: config_env(),
    API_KEY_GEMINI: "AIzaSyA_R4-EgM1mDZXkXkdFXEdFUjXNFGuGMG4",
    URL_GEMINI: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=",
    GEMINI_CRONTAB: "* 4 * * *"
end

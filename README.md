Yogi Berra Scoreboard
=====================
This is the rails app which allows you to view and search
for the exceptions caught by https://github.com/earlonrails/yogi_berra gem.

Installation
------------

clone, bundle, and point the mongoid.yml to your mongodb database. ex.

    development:
      # Configure available database sessions. (required)
      sessions:
        # Defines the default session. (required)
        default:
          # Defines the name of the default database that Mongoid can connect to.
          # (required).
          database: yogi_berra
          # Provides the hosts the default session can connect to. Must be an array
          # of host:port pairs. (required)
          hosts:
            - localhost:27017
          options:
            # Change whether the session persists in safe mode by default.
            # (default: false)
            # safe: false

            # Change the default consistency model to :eventual or :strong.
            # :eventual will send reads to secondaries, :strong sends everything
            # to master. (default: :eventual)
            # consistency: :eventual

            # How many times Moped should attempt to retry an operation after
            # failure. (default: 30)
            # max_retries: 30

            # The time in seconds that Moped should wait before retrying an
            # operation on failure. (default: 1)
            # retry_interval: 1
      # Configure Mongoid specific options. (optional)
      options:
        # Configuration for whether or not to allow access to fields that do
        # not have a field definition on the model. (default: true)
        # allow_dynamic_fields: true

        # Enable the identity map, needed for eager loading. (default: false)
        # identity_map_enabled: false

        # Includes the root model name in json serialization. (default: false)
        # include_root_in_json: false

        # Include the _type field in serializaion. (default: false)
        # include_type_for_serialization: false

        # Preload all models in development, needed when models use
        # inheritance. (default: false)
        # preload_models: false

        # Protect id and type from mass assignment. (default: true)
        # protect_sensitive_fields: true

        # Raise an error when performing a #find and the document is not found.
        # (default: true)
        # raise_not_found_error: true

        # Raise an error when defining a scope with the same name as an
        # existing method. (default: false)
        # scope_overwrite_exception: false

        # Skip the database version check, used when connecting to a db without
        # admin access. (default: false)
        # skip_version_check: false

        # User Active Support's time zone in conversions. (default: true)
        # use_activesupport_time_zone: true

        # Ensure all times are UTC in the app side. (default: false)
        # use_utc: false
    test:
      sessions:
        default:
          database: yogi_berra_test
          hosts:
            - localhost:27017
          options:
            consistency: :strong
            # In the test environment we lower the retries and retry interval to
            # low amounts for fast failures.
            max_retries: 1
            retry_interval: 0

Full Text Search
----------------
Scoreboard is now using full text search with mongodb.
To setup, in your mongodb.conf file: 

    # enable full text search
    setParameter=textSearchEnabled=true

Then restart your mongod service.


Create Index
------------
    # for full text searching
    db.caught_exceptions.ensureIndex({ "$**": "text" }, { name: "TextIndex" })
    # for faster date range sorting
    db.caught_exceptions.ensureIndex({"created_at": 1})
    /*
     * optional TTL
     * 2592000 - after one month delete record
     * db.caught_exceptions.ensureIndex({"created_at": 1}, { expireAfterSeconds: 2592000 } )
     *
     * alternate option Capped Collection
     * db.caught_exceptions.ensureIndex({"created_at": 1}, { expireAfterSeconds: 2592000 } )
     */
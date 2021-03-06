# Changelog

## v0.2.0 (2019-03-18)

### Enhancements

* Add `:disconnect_on_error_codes` option to `MyXQL.start_link/1`
* Add `:ping_timeout` option to `MyXQL.start_link/1`
* Add `:handshake_timeout` option to `MyXQL.start_link/1`
* Add `:num_warnings` field to `MyXQL.Result`
* Add `:connection_id` field to `MyXQL.Error`
* Add `query_type: :binary | :binary_then_text | :text` option to `MyXQL.query/4`
* Improve handshake socket errors handling
* Raise error when both :username option and USER env are missing
* Add `MARIAEX_COMPATIBILITY.md` page

### Bug fixes

* Actually disconnect on `ER_MAX_PREPARED_STMT_COUNT_REACHED`
* Encode JSON values in binary protocol
* Gracefully error when server does not support `CLIENT_DEPRECATE_EOF`
* Use `:connect_timeout` option for connecting to SSL socket

### Backwards incompatible changes

* Use binary protocol by default in `MyXQL.query/4`
* Return an additional leading result in `MyXQL.stream/4`.
  The leading result is of executing the query but not yet fetching data.
* Remove `:ssl` from application list

## v0.1.1 (2019-01-24)

* Raise better error message when a parameter cannot be encoded
* Raise a better error when query to be executed is not prepared
* Raise error on multiple results and point to instead using `MyXQL.stream/4`
* Fix streaming inserts
* Fix transaction handling for savepoints
* Disconnect the connection on `ER_MAX_PREPARED_STMT_COUNT_REACHED` error
* Add MySQL error code and name to exception message
* Add `:prepare` connection option

## v0.1.0 (2019-01-22)

* Initial release

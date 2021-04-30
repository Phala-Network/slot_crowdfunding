Phala slot crowdfunding
====

Phala slot crowdfunding backend

## Dependencies

- Ruby 3.0.1
- SQLite / PostgreSQL
- NodeJS 14+

## Preparation

### Install dependencies

- `bundle install`
- `cd vendor/polkadot_js_snippets && yarn install`

### Rails configs

- `cp config/database.yml.example config/database.yml`
  - Edit it
- `cp config/credentials.yml.example config/credentials.yml`
  - Run `rails secret` for a new secret seed then replace the default in `credentials.yml`
  - Run `rails credentials:encrypt`

### Check seed

- Edit `db/seed.rb` if need

### Create database

- For development `rails db:reset`
- For production `RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:reset`

## Run

### Block fetcher service

`cd vendor/polkadot_js_snippets && yarn start --port 3001 --endpoint http://127.0.0.1:9933`

> `http://127.0.0.1:9933` is RPC port of Kusama node with `--pruning=archive` argument, it's highly recommend self host one locally.

### Scanner service

`RAILS_ENV=production script/fast_fetch_contribution_events.rb kusama`

### API service

`rails s -e production`

## License

[MIT License](https://opensource.org/licenses/MIT).

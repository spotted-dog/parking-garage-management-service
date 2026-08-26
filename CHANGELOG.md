# Changelog

All notable changes to this project are documented in this file.

## [0.0.2] - 2026-08-26

Added UI to create a garage.

### Added

- `GET /garages/new`: a Leaf-rendered page for creating a garage. The form takes the garage
  name and a dynamic per-floor list of space counts (add/remove floors), and submits to the
  existing `POST /garages` API, displaying the assigned floor/space numbers or the server's
  error message.

## [0.0.1] - 2026-08-26

Initial garage creation.

### Added

- `POST /garages` to create a garage: caller specifies a name and, per floor, only the number of
  spaces - the service assigns floor numbers (`f1`, `f2`, ...) and space numbers (`1001`-`1003`,
  `2001`-`2002`, ...) automatically. Each floor can have a different number of spaces.
- `GET /garages` to list garages with their full floor/space hierarchy.
- `Garage`, `Floor`, and `Space` Fluent models, migrations, and DTOs.
- `CLAUDE.md` project guidance and `sql/database_setup.sql` for the `garage_manager` schema setup.

### Fixed

- `configure.swift` now sets the Postgres `search_path` from `DATABASE_SCHEMA`, so Fluent
  migrations target the `garage_manager` schema instead of `public`, which the database roles
  are not granted access to.

### Removed

- Vapor project template scaffolding left over from project generation: the `Todo` resource
  (model, DTO, migration, controller), and the template's root/`hello` routes and Leaf view.

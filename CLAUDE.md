# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Running Tests
```bash
# Run all tests
bundle exec rspec spec
# or
rake spec

# Run a specific test file
bundle exec rspec spec/unit/properties_spec.rb

# Run tests with specific line number
bundle exec rspec spec/unit/properties_spec.rb:42

# Run tests matching a pattern
bundle exec rspec spec/unit/*_spec.rb

# Run tests with documentation format
bundle exec rspec spec --format documentation
```

### Development Setup
```bash
# Install dependencies
bundle install

# Start Guard for automatic test running
bundle exec guard
```

## Architecture

### Core Module Structure
CouchRest Model uses a modular architecture where functionality is mixed into the Base class:

- **CouchRest::Model::Base** - Main class that all models inherit from, built on CouchRest::Document
- **Properties** - Property definitions with typecasting support
- **Persistence** - CRUD operations and database interactions
- **Callbacks** - ActiveModel callbacks integration (before/after save, create, update, destroy)
- **Validations** - ActiveModel validations with custom validators
- **Dirty** - Change tracking using Hashdiff for deep nested structure tracking
- **Associations** - belongs_to, has_many relationships
- **Designs** - CouchDB design document and view management

### Key Design Patterns

1. **ActiveModel Integration**: Heavy use of ActiveModel for Rails compatibility
2. **Design Documents**: Views are managed through design documents with automatic migration
3. **Connection Pooling**: Server pool management for multiple CouchDB connections
4. **Proxy Pattern**: Models can be proxied to different databases dynamically

### Database Configuration
- Looks for `config/couchdb.yml` for Rails-style database configuration
- Supports environment-specific settings (development, test, production)
- Database names follow pattern: `prefix_[model_database]_suffix`

### Testing Approach
- Uses RSpec 3.5.0
- Tests split into unit (`spec/unit/`) and functional (`spec/functional/`)
- Test models in `spec/fixtures/`
- Uses test database named `couchrest-model-test`

### Current Development Focus
The `rails7_callback_wrapper` branch indicates work on Rails 7 compatibility, specifically:
- Refactoring callback system
- New `update_hook_guard.rb` implementation
- Removal of `skip_double_wrap.rb`
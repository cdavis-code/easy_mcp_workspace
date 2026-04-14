# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-04-13
### Fixed
- Widen analyzer constraint to support latest versions
- Add example for package usage
- Fix lint issues and improve pana score

## [0.1.0] - 2026-04-13
### Added
- Initial release of mcp_generator package
- Build runner generator for @tool annotations
- AST-based parsing using dart:analyzer and source_gen
- Support for both stdio (JSON-RPC) and HTTP (Shelf) transports
- Automatic JSON-Schema generation from Dart types
- Dynamic method dispatch in generated servers
- Template-based code generation with StdioTemplate and HttpTemplate
- Doc comment extraction for tool descriptions
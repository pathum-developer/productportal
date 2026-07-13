# Changelog

All notable changes to Product Portal are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- PostgreSQL runtime support with PostgreSQL JDBC driver
- Flyway PostgreSQL schema, trigger, and seed migrations
- Two-query fetch-join pagination pattern for scalable user listing
- Custom multi-column sorting with SQL injection prevention
- Sort parameter validation via UserSortColumn enum
- SortValidator utility for safe sort parameter handling
- Comprehensive OpenAPI/Swagger documentation
- GitHub Actions CI/CD workflow
- Professional README and contributing guides

### Changed
- Migrated default datasource configuration and Docker Compose database from MySQL to PostgreSQL
- Converted MySQL-specific native queries to PostgreSQL-compatible SQL
- User pagination endpoint now accepts Pageable parameters
- Repository query refactored to support dynamic sorting
- Service layer includes sort validation

### Fixed
- N+1 query problems via fetch-join strategy
- Hibernate pagination bugs with collection fetches

---

## [v1.0.0] - Initial Release

### Added
- User registration endpoint with role assignment
- User details retrieval by username
- Paginated user listing by status
- JWT authentication integration
- Role-based access control (RBAC)
- Password hashing with BCrypt
- User status management (ACTIVE, INACTIVE, SUSPENDED)
- User roles (BUYER, SELLER, ADMIN)
- User addresses support (1:M relationship)
- Comprehensive input validation
- Global exception handling
- AOP-based execution time monitoring
- Audit fields (createdAt, updatedAt) on entities
- MySQL database integration
- Spring Security integration
- Swagger UI for API documentation

### Features
- ✅ Enterprise-grade architecture
- ✅ Two-query pagination pattern
- ✅ SQL injection prevention
- ✅ N+1 query optimization
- ✅ RESTful API design
- ✅ Clean code practices
- ✅ Transaction management
- ✅ Spring Data JPA integration

---

## Versioning Strategy

- **MAJOR** (v1.0.0) — Breaking changes to API or core functionality
- **MINOR** (v1.1.0) — New features (backward compatible)
- **PATCH** (v1.0.1) — Bug fixes (backward compatible)

### Release Schedule
- Monthly minor releases
- Weekly patch releases
- Major releases as needed

---

## Future Roadmap

### Planned for v1.1.0
- [ ] Keyset/cursor pagination support
- [ ] Caching for reference data (roles, statuses)
- [ ] Three-query pattern for large result sets
- [ ] Rate limiting

### Planned for v1.2.0
- [ ] Product management API
- [ ] Category hierarchy with recursive CTEs
- [ ] Search functionality
- [ ] Advanced filtering

### Planned for v2.0.0
- [ ] GraphQL support
- [ ] WebSocket real-time updates
- [ ] API versioning strategy
- [ ] Distributed caching

---

## Notes

- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- See [README.md](README.md) for project overview
- See [GITHUB_PUSH_GUIDE.md](GITHUB_PUSH_GUIDE.md) for deployment instructions
